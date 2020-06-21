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

  def transactions
    @selected_left_navi_link = "transactions"
    @service = Person::SettingsService.new(community: @current_community, params: params)
    params[:page] = 1 unless request.xhr?
    pagination_opts = PaginationViewUtils.parse_pagination_opts(params)
    count = InboxService.inbox_data_count(@current_user.id, @current_community.id)
    transactional_inbox_rows = transactional_inbox_rows(pagination_opts, count)
    sorted_activity_dates = transactional_inbox_rows.pluck(:last_transition_at)
    if request.xhr?
      if sorted_activity_dates.present? && transactional_inbox_rows.next_page.present?
        bucks_histories_in_between_sorted_activity_dates = @current_user.avon_bucks_histories
                                                              .where.not(id: session[:avon_bucks_ids])
                                                              .where(transaction_id: nil)
                                                              .where("created_at <= ? AND created_at >= ?", 
                                                                  sorted_activity_dates.first.to_date.end_of_day, sorted_activity_dates.last.to_date.beginning_of_day
                                                              )
      else
        bucks_histories_in_between_sorted_activity_dates = @current_user.avon_bucks_histories
                                                              .where.not(id: session[:avon_bucks_ids])
                                                              .where(transaction_id: nil)         
      end
    else
      if sorted_activity_dates.present? && transactional_inbox_rows.next_page.present?
          bucks_histories_in_between_sorted_activity_dates = @current_user.avon_bucks_histories
                                                                .where(transaction_id: nil)
                                                                .where("created_at <= ? AND created_at >= ?", 
                                                                    sorted_activity_dates.first.to_date.end_of_day, sorted_activity_dates.last.to_date.beginning_of_day
                                                                )        
      else
        bucks_histories_in_between_sorted_activity_dates = @current_user.avon_bucks_histories.where(transaction_id: nil) 
      end     
    end

    unless bucks_histories_in_between_sorted_activity_dates.blank?
      arranged_histories_rows = []
      bucks_histories_in_between_sorted_activity_dates.each do |history|
        arranged_hash = {
          type: 'avon_bucks'.to_sym,
          id: history.id,
          person_id: history.person_id,
          operator_id: history.operator_id,
          amount: history.amount,
          operation: history.operation,
          last_transition_at: history.created_at.to_time
        }
        arranged_histories_rows << arranged_hash
      end

      flatten_tx_rows = (transactional_inbox_rows + arranged_histories_rows).flatten
      result_rows = flatten_tx_rows.sort_by! { |r| r[:last_transition_at] }.reverse
    end

    result_rows = result_rows.present? ? result_rows : transactional_inbox_rows

    if request.xhr?
      session[:avon_bucks_ids] = (session[:avon_bucks_ids] + bucks_histories_in_between_sorted_activity_dates.pluck(:id)).flatten.uniq
      render :partial => "transaction_row", 
        :collection => result_rows, :as => :conversation, 
        locals: { 
          payments_in_use: @current_community.payments_in_use? 
        }
    else
      session[:avon_bucks_ids] = bucks_histories_in_between_sorted_activity_dates.pluck(:id)
      render locals: {
        transactional_inbox_rows: transactional_inbox_rows,
        result_rows: result_rows,
        payments_in_use: @current_community.payments_in_use?
      }
    end         
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

  private


  def find_person_to_unsubscribe(current_user, auth_token)
    current_user || Maybe(AuthToken.find_by_token(auth_token)).person.or_else { nil }
  end

end
