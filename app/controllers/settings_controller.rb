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

  def offers_and_request
    @selected_left_navi_link = "offers_and_request"
    @service = Person::SettingsService.new(community: @current_community, params: params)
    if params[:start_date].present? && params[:end_date].present?
      start_date = Date.strptime(params[:start_date],"%m/%d/%Y")
      end_date = Date.strptime(params[:end_date],"%m/%d/%Y")
      transactions = transactions.where(created_at: start_date.beginning_of_day..end_date.end_of_day)
    end
    scope_listings = resource_scope

    #expired listings
    expired_listing_ids = []
    scope_listings.each do |listing|
      if listing.valid_until && listing.valid_until < DateTime.current
        expired_listing_ids << listing.id
      end
    end
    all_expired_listings = scope_listings.where(id: expired_listing_ids)

    if params[:status].present? && params[:listing_title].present?
      if params[:status].eql?('expired')
        scope_listings = all_expired_listings.where(title: params[:listing_title])
      else
        scope_listings = scope_listings.where(open: params[:status].eql?('open'), title: params[:listing_title])
      end
    else
      if params[:status].present?
        if params[:status].eql?('expired')
          scope_listings = all_expired_listings
        else
          scope_listings = scope_listings.where(open: params[:status].eql?('open'))
        end
      else
        scope_listings = scope_listings.where(title: params[:listing_title])
      end
    end
    respond_to do |format|
      format.html do
        @listings = scope_listings.order("#{sort_column} #{sort_direction}")
                .paginate(:page => params[:page], :per_page => 30)        
      end

      format.csv do
        all_listings = scope_listings

        marketplace_name = @current_community.use_domain ? @current_community.domain : @current_community.ident

        self.response.headers["Content-Type"] ||= 'text/csv'
        self.response.headers["Content-Disposition"] = "attachment; filename=#{marketplace_name}-listings-#{Date.today}.csv"
        self.response.headers["Content-Transfer-Encoding"] = "binary"
        self.response.headers["Last-Modified"] = Time.now.ctime.to_s

        self.response_body = Enumerator.new do |yielder|
          generate_csv_for(yielder, all_listings, @current_community)
        end
      end
    end
  end

  def transactions
    @selected_left_navi_link = "transactions"
    @service = Person::SettingsService.new(community: @current_community, params: params)
  end

  def transactional_inbox_rows(pagination_opts, count)
    inbox_rows = InboxService.inbox_data(
      @current_user.id,
      @current_community.id,
      pagination_opts[:limit],
      pagination_opts[:offset])

    inbox_rows = inbox_rows.select{|item| item[:type].eql?(:transaction)}

    inbox_rows = inbox_rows.map { |inbox_row|
      extended_inbox = inbox_row.merge(
        path: path_to_conversation_or_transaction(inbox_row),
        last_activity_ago: time_ago(inbox_row[:last_activity_at]),
        title: inbox_title(inbox_row, inbox_payment(inbox_row))
      )

      if inbox_row[:type] == :transaction
        extended_inbox.merge(
          listing_url: listing_path(id: inbox_row[:listing_id])
        )
      else
        extended_inbox
      end       
    }

    paginated_inbox_rows = WillPaginate::Collection.create(pagination_opts[:page], pagination_opts[:per_page], count) do |pager| 
      pager.replace(inbox_rows) 
    end
  end

  def inbox_title(inbox_item, payment_sum)
    title = if InboxService.last_activity_type(inbox_item) == :message
      inbox_item[:last_message_content]
    else
      action_messages = TransactionViewUtils.create_messages_from_actions(
        inbox_item[:transitions],
        inbox_item[:other],
        inbox_item[:starter],
        payment_sum,
        inbox_item[:payment_gateway],
        inbox_item[:community_id]
      )

      action_messages.last[:content]
    end
  end

  def inbox_payment(inbox_item)
    Maybe(inbox_item)[:payment_total].or_else(nil)
  end

  def path_to_conversation_or_transaction(inbox_item)
    if inbox_item[:type] == :transaction
      person_transaction_path(:person_id => inbox_item[:current][:username], :id => inbox_item[:transaction_id])
    else
      single_conversation_path(:conversation_type => "received", :id => inbox_item[:conversation_id])
    end
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

  def sort_column
    case params[:sort]
    when 'started'
      'listings.created_at'
    when 'updated', nil
      'listings.updated_at'
    when 'category'
      'categories.url'
    when 'featured'
      'listings.featured'
    end
  end

  def sort_direction
    params[:direction] == 'asc' ? 'asc' : 'desc'
  end

  private

  def resource_scope
    @current_community.listings.exist.includes(:author, :category)
  end

  def find_person_to_unsubscribe(current_user, auth_token)
    current_user || Maybe(AuthToken.find_by_token(auth_token)).person.or_else { nil }
  end

end
