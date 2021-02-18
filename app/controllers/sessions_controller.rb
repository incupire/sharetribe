require 'rest_client'

class SessionsController < ApplicationController

  skip_before_action :cannot_access_if_banned, :only => [ :destroy, :confirmation_pending ]
  skip_before_action :cannot_access_without_confirmation, :only => [ :destroy, :confirmation_pending ]
  skip_before_action :ensure_consent_given, only: [ :destroy, :confirmation_pending ]
  skip_before_action :ensure_user_belongs_to_community, :only => [ :destroy, :confirmation_pending ]

  # For security purposes, Devise just authenticates an user
  # from the params hash if we explicitly allow it to. That's
  # why we need to call the before filter below.
  before_action :allow_params_authentication!, :only => :create

  def new
    if params[:return_to].present?
      session[:return_to] = params[:return_to]
    end

    @selected_tribe_navi_tab = "members"
    @facebook_merge = session["devise.facebook_data"].present?
    if @facebook_merge
      @facebook_email = session["devise.facebook_data"]["email"]
      @facebook_name = "#{session["devise.facebook_data"]["given_name"]} #{session["devise.facebook_data"]["family_name"]}"
    end
  end

  def create
    session[:form_login] = params[:person][:login]

    # Start a session with Devise

    # In case of failure, set the message already here and
    # clear it afterwards, if authentication worked.
    flash.now[:error] = t("layouts.notifications.login_failed")

    # Since the authentication happens in the rack layer,
    # we need to tell Devise to call the action "sessions#new"
    # in case something goes bad.
    person = authenticate_person!(:recall => "sessions#new")
    @current_user = person

    flash[:error] = nil

    # Store Facebook ID and picture if connecting with FB
    if session["devise.facebook_data"]
      @current_user.update_attribute(:facebook_id, session["devise.facebook_data"]["id"])
      # FIXME: Currently this doesn't work for very unknown reason. Paper clip seems to be processing, but no pic
      if @current_user.image_file_size.nil?
        @current_user.store_picture_from_facebook!
      end
    end

    sign_in @current_user

    setup_intercom_user

    session[:form_login] = nil

    unless @current_user.is_admin? || terms_accepted?(@current_user, @current_community)
      sign_out @current_user
      session[:temp_cookie] = "pending acceptance of new terms"
      session[:temp_person_id] =  @current_user.id
      session[:temp_community_id] = @current_community.id
      session[:consent_changed] = true if @current_user
      redirect_to terms_path and return
    end

    flash[:notice] = t("layouts.notifications.login_successful", person_name: view_context.link_to(PersonViewUtils.person_display_name_for_type(@current_user, "first_name_only"), person_path(@current_user))).html_safe
    if session[:return_to]
      redirect_to session[:return_to]
      session[:return_to] = nil
    elsif session[:return_to_content]
      redirect_to session[:return_to_content]
      session[:return_to_content] = nil
    else
      redirect_to search_path
    end
  end

  def destroy
    logged_out_user = @current_user
    sign_out

    # Admin Intercom shutdown
    IntercomHelper::ShutdownHelper.intercom_shutdown(session, cookies, request.host_with_port)

    flash[:notice] = t("layouts.notifications.logout_successful")
    mark_logged_out(flash, logged_out_user)
    redirect_to landing_page_path
  end

  def index
    redirect_to login_path
  end

  def request_new_password
    person =
      Person
      .joins("LEFT OUTER JOIN emails ON emails.person_id = people.id")
      .where("emails.address = :email AND (people.is_admin = '1' OR people.community_id = :cid)", email: params[:email], cid: @current_community.id)
      .first
    if person
      token = person.reset_password_token_if_needed
      MailCarrier.deliver_later(PersonMailer.reset_password_instructions(person, params[:email], token, @current_community))
      flash[:notice] = t("layouts.notifications.password_recovery_sent")
    else
      flash[:error] = t("layouts.notifications.email_not_found")
    end

    redirect_to login_path
  end

  def facebook
    omniauth_setup('facebook')
  end

  def linkedin
    omniauth_setup('linkedin')
  end

  def twitter
    if params[:testimonial_id].present?
      testimonial = Testimonial.find(params[:testimonial_id])
      client = Twitter::REST::Client.new do |config|
        config.consumer_key     = APP_CONFIG.twitter_app_id
        config.consumer_secret  = APP_CONFIG.twitter_app_secret
        config.access_token     = request.env["omniauth.auth"]['extra']['access_token'].token
        config.access_token_secret = request.env["omniauth.auth"]['extra']['access_token'].secret
      end
      result = client.update_with_media("#{person_url(testimonial.receiver)}", download_to_file(testimonial.snapshot.url)) rescue nil
      if result.nil?
        flash[:error] = 'Something went wrong. Please try again'
      else
        flash[:notice] = 'Review successfully shared'
      end
    else
      flash[:error] = 'Something went wrong. Please try again'
    end
    redirect_to share_on_twitter_success_people_path
  end

  def download_to_file(uri)
    stream = open(uri, "rb")
    return stream if stream.respond_to?(:path)
    Tempfile.new.tap do |file|
      file.binmode
      IO.copy_stream(stream, file)
      stream.close
      file.rewind
    end
  end

  def omniauth_setup(provider)
    data = request.env["omniauth.auth"].extra.raw_info
    if provider.eql?('linkedin')
      data = request.env["omniauth.auth"].info
      data[:uid] = request.env["omniauth.auth"].uid
    end
    origin_locale = get_origin_locale(request, available_locales())
    I18n.locale = origin_locale if origin_locale

    persons = Person
              .includes(:emails, :community_memberships)
              .references(:emails)
              .where(["people.facebook_id = ? OR people.linkedin_id =? OR emails.address = ?", data.id, data.uid, data.email]).uniq

    people_in_this_community = persons.select { |p| p.is_admin? || p.community_memberships.map(&:community_id).include?(@current_community.id) }
    person_by_auth_id = if provider.eql?('facebook')
      people_in_this_community.find { |p| p.facebook_id == data.id }
    elsif provider.eql?('linkedin')
      people_in_this_community.find { |p| p.linkedin_id == data.uid }
    end
    person_by_email = people_in_this_community.find { |p| p.emails.any? { |e| e.address == data.email && e.confirmed_at.present? } }
    email_unconfirmed = people_in_this_community.flat_map(&:emails).find { |e| e.address == data.email && e.confirmed_at.blank? }.present?

    person = person_by_auth_id || person_by_email
    if person
      person.update_facebook_data(data.id)
      if provider.eql?('linkedin')
        image = data&.picture_url
        person.update_linkedin_data(data.uid, image)
      end
      flash[:notice] = t("devise.omniauth_callbacks.success", :kind => provider.capitalize)
      sign_in_and_redirect person, event: :authentication
    elsif data.email.blank?
      flash[:error] = t("layouts.notifications.could_not_get_email_from_#{provider}")
      redirect_to sign_up_path and return     
    elsif email_unconfirmed
      flash[:error] = t("layouts.notifications.#{provider}_email_unconfirmed", email: data.email)
      redirect_to login_path and return
    else
      omniauth_data = set_omniauth_session(data, provider)
      session["devise.omniauth_data"] = omniauth_data
      redirect_to :action => :create_omniauth_based, :controller => :people
    end
  end

  def set_omniauth_session(data, provider)
    if provider.eql?('facebook')
      {
        "email"       => data.email,
        "given_name"  => data.first_name,
        "family_name" => data.last_name,
        "username"    => data.username,
        "id"          => data.id
      }
    elsif provider.eql?('linkedin')
      {
        "email"       => data.email,
        "given_name"  => data.first_name,
        "family_name" => data.last_name,
        "username"    => data.username,
        "id"          => data.uid,
        "kind"        => 'linkedin',
        "image"       => data.picture_url
      }
    end
  end

  # Facebook setup phase hook, that is used to dynamically set up a omniauth strategy for facebook on customer basis
  def facebook_setup
    request.env["omniauth.strategy"].options[:iframe] = true
    request.env["omniauth.strategy"].options[:scope] = "public_profile,email"
    request.env["omniauth.strategy"].options[:info_fields] = "name,email,last_name,first_name"

    if @current_community.facebook_connect_enabled?
      request.env["omniauth.strategy"].options[:client_id] = @current_community.facebook_connect_id || APP_CONFIG.fb_connect_id
      request.env["omniauth.strategy"].options[:client_secret] = @current_community.facebook_connect_secret || APP_CONFIG.fb_connect_secret
    else
      # to prevent plain requests to /people/auth/facebook even when "login with Facebook" button is hidden
      request.env["omniauth.strategy"].options[:client_id] = ""
      request.env["omniauth.strategy"].options[:client_secret] = ""
      request.env["omniauth.strategy"].options[:client_options][:authorize_url] = login_url
      request.env["omniauth.strategy"].options[:client_options][:site_url] = login_url
    end

    render :plain => "Setup complete.", :status => 404 #This notifies the ominauth to continue
  end

  # Callback from Omniauth failures
  def failure
    origin_locale = get_origin_locale(request, available_locales())
    I18n.locale = origin_locale if origin_locale
    error_message = params[:error_reason] || "login error"
    kind = request.env["omniauth.error.strategy"].name.to_s || "Facebook"
    flash[:error] = t("devise.omniauth_callbacks.failure",:kind => kind.humanize, :reason => error_message.humanize)
    redirect_to search_path
  end
  
  def passthru
    render status: 404, plain: "Not found. Authentication passthru."
  end
  private

  def terms_accepted?(user, community)
    user && community.consent.eql?(user.consent)
  end

  def get_origin_locale(request, available_locales)
    locale_string ||= URLUtils.extract_locale_from_url(request.env['omniauth.origin']) if request.env['omniauth.origin']
    if locale_string && available_locales.include?(locale_string)
      locale_string
    end
  end

end
