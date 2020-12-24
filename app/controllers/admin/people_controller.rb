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

  def validate_listing_author
    author = Person.joins(:emails).where(emails: {address: params[:listing][:author_id]}).first
    respond_to do |format|
      format.json { render :json => author.present? ? true : false }
    end
  end

  # def destroy
  #   target_user = Person.find_by!(username: params[:id], community_id: @current_community.id)

  #   has_unfinished = TransactionService::Transaction.has_unfinished_transactions(target_user.id)
  #   only_admin = @current_community.is_person_only_admin(target_user)

  #   return redirect_to search_path if has_unfinished || only_admin

  #   stripe_del = StripeService::API::Api.accounts.delete_seller_account(community_id: @current_community.id,
  #                                                                       person_id: target_user.id)
  #   unless stripe_del[:success]
  #     flash[:error] =  t("layouts.notifications.stripe_you_account_balance_is_not_0")
  #     return redirect_to search_path
  #   end

  #   # Do all delete operations in transaction. Rollback if any of them fails
  #   ActiveRecord::Base.transaction do
  #     Person.delete_user(target_user.id)
  #     Listing.delete_by_author(target_user.id)
  #     PaypalAccount.where(person_id: target_user.id, community_id: target_user.community_id).delete_all
  #   end

  #   #sign_out target_user
  #   record_event(flash, 'user', {action: "deleted", opt_label: "by user"})
  #   flash[:notice] = t("layouts.notifications.account_deleted_by_admin")
  #   redirect_to admin_community_community_memberships_path(@current_community, sort: "join_date", direction: "desc")
  # end  

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
