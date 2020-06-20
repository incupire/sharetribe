class SettingsController < ApplicationController

  before_action :except => :unsubscribe do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_view_your_settings")
  end

  before_action EnsureCanAccessPerson.new(:person_id, error_message_key: "layouts.notifications.you_are_not_authorized_to_view_this_content"), except: :unsubscribe

  def show
    @selected_left_navi_link = "profile"
    @service = Person::SettingsService.new(community: @current_community, params: params)
    @service.add_location_to_person
    flash.now[:notice] = t("settings.profile.image_is_processing") if @service.image_is_processing?
  end

  def account
    target_user = Person.find_by!(username: params[:person_id], community_id: @current_community.id)
    @selected_left_navi_link = "account"
    target_user.emails.build
    has_unfinished = TransactionService::Transaction.has_unfinished_transactions(target_user.id)
    only_admin = @current_community.is_person_only_admin(target_user)

    render locals: {has_unfinished: has_unfinished, target_user: target_user, only_admin: only_admin}
  end

  def reload_your_balance
    avontage = Person.find_by(username: 'avontage')
    @received_testimonials = TestimonialViewUtils.received_testimonials_in_community(avontage, @current_community)
    @received_positive_testimonials = TestimonialViewUtils.received_positive_testimonials_in_community(avontage, @current_community)
    @feedback_positive_percentage = avontage.feedback_positive_percentage_in_community(@current_community)
    if request.post?
      begin
        balance = params[:custom_balance].to_f > 0 ? params[:custom_balance].to_f : params[:balance].to_f
        balance = Money.new(balance * 100, @current_community.currency)
        res = StripeService::API::Api.wrapper.reload_balance(community_id: @current_community.id,
                                                            amount: balance.cents, currency: @current_community.currency,
                                                            description: "#{@current_user.given_name.to_s} #{@current_user.family_name} reloaded his Avontage Bucks Balance",
                                                            card_token: params[:stripe_token])

        if res.status.present? && res.status.eql?('succeeded')
          @current_user.increment!(:coupon_balance_cents, balance.cents)
          AvonBucksHistory.create(
            amount: MoneyUtil.to_money(balance.cents, @current_community.currency),
            operation: 'self added',
            remaining_balance: @current_user.coupon_balance,
            person_id: @current_user.id,
            operator_id:  @current_user.id,
            currency: @current_community.currency,
            stripe_charge_id: res.id
          )
          flash[:notice] = "Your Avontage Bucks Balance successfully reloaded"
        else
          flash[:error] = "Something went wrong. Please try again"
        end
      rescue Exception => e
        flash[:error] = e.message
      end
    end
  end

  def notifications
    target_user = Person.find_by!(username: params[:person_id], community_id: @current_community.id)
    @selected_left_navi_link = "notifications"
    render locals: {target_user: target_user}
  end

  def unsubscribe
    target_user = find_person_to_unsubscribe(@current_user, params[:auth])

    if target_user && target_user.username == params[:person_id] && params[:email_type].present?
      if params[:email_type] == "community_updates"
        target_user.unsubscribe_from_community_updates
      elsif [Person::EMAIL_NOTIFICATION_TYPES, Person::EMAIL_NEWSLETTER_TYPES].flatten.include?(params[:email_type])
        target_user.preferences[params[:email_type]] = false
        target_user.save!
      else
        render :unsubscribe, :status => :bad_request, locals: {target_user: target_user, unsubscribe_successful: false} and return
      end
      render :unsubscribe, locals: {target_user: target_user, unsubscribe_successful: true}
    else
      render :unsubscribe, :status => :unauthorized, locals: {target_user: target_user, unsubscribe_successful: false}
    end
  end

  private


  def find_person_to_unsubscribe(current_user, auth_token)
    current_user || Maybe(AuthToken.find_by_token(auth_token)).person.or_else { nil }
  end

end
