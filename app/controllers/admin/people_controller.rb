class Admin::PeopleController < Admin::AdminBaseController
  def new
    @person = if params[:person] then
      Person.new(params[:person].slice(:given_name, :family_name, :email, :username).permit!)
    else
      Person.new()
    end
  end

  def create
    domain = @current_community ? @current_community.full_url : "#{request.protocol}#{request.host_with_port}"
    error_redirect_path = domain + sign_up_path

    if params[:person].blank? || params[:person][:input_again].present? # Honey pot for spammerbots
      flash[:error] = t("layouts.notifications.registration_considered_spam")
      ApplicationHelper.send_error_notification("Registration Honey Pot is hit.", "Honey pot")
      redirect_to error_redirect_path and return
    end

    # Check that email is not taken
    unless Email.email_available?(params[:person][:email], @current_community.id)
      flash[:error] = t("people.new.email_is_in_use")
      redirect_to error_redirect_path and return
    end

    # Check that the email is allowed for current community
    if @current_community && ! @current_community.email_allowed?(params[:person][:email])
      flash[:error] = t("people.new.email_not_allowed")
      redirect_to error_redirect_path and return
    end

    @person, email = new_person(params, @current_community)

    # Make person a member of the current community
    if @current_community
      membership = CommunityMembership.new(:person => @person, :community => @current_community, :consent => @current_community.consent)
      membership.status = "accepted"
      membership.save!
    end

    email.confirm!

    redirect_to admin_community_community_memberships_path(@current_community)
  end

  private

    # Create a new person by params and current community
    def new_person(initial_params, current_community)
      initial_params[:person][:locale] =  params[:locale] || APP_CONFIG.default_locale
      initial_params[:person][:test_group_number] = 1 + rand(4)
      initial_params[:person][:community_id] = current_community.id

      params = person_create_params(initial_params)
      person = Person.new(params)

      email = Email.new(:person => person, :address => params[:email].downcase, :send_notifications => true, community_id: current_community.id)
      params.delete(:email)

      # person = build_devise_resource_from_person(params)

      person.emails << email

      person.inherit_settings_from(current_community)
      person.save!

      person.set_default_preferences

      [person, email]
    end

    def person_create_params(params)
      params.require(:person).slice(
          :given_name,
          :family_name,
          :display_name,
          :street_address,
          :phone_number,
          :image,
          :description,
          :location,
          :password,
          :password2,
          :locale,
          :email,
          :username,
          :community_id
      ).permit!
    end
end
