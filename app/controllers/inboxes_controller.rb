class InboxesController < ApplicationController
  include MoneyRails::ActionViewExtension
  include Collator

  before_action do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_view_your_inbox")
  end

  def show
    # We use pageless scroll, so the page should be always the first one (1) when request was not AJAX request
    params[:page] = 1 unless request.xhr?

    pagination_opts = PaginationViewUtils.parse_pagination_opts(params)

    inbox_rows = InboxService.inbox_data(
      @current_user.id,
      @current_community.id,
      pagination_opts[:limit],
      pagination_opts[:offset],nil, nil, nil, 'inbox')

    count = InboxService.inbox_data_count(@current_user.id, @current_community.id)
    # Inbox is used FOR DIRECT MESSAGING/ASK SELLEROPTIONS
    # inbox_rows = inbox_rows.select{|item| item[:type].eql?(:conversation)}

    inbox_rows = inbox_rows.map { |inbox_row|
      extended_inbox = inbox_row.merge(
        path: path_to_conversation_or_transaction(inbox_row),
        last_activity_ago: time_ago(inbox_row[:last_activity_at]),
        title: inbox_title(inbox_row, inbox_payment(inbox_row)),
      )

      conversation = Conversation.find(inbox_row[:conversation_id])
      if conversation.listing_id.present?
        extended_inbox.merge(
          listing_deleted: conversation.listing.deleted,
          listing_title: conversation&.listing&.title,
          listing_url: listing_path(id: conversation.listing_id)
        )
      else
        extended_inbox
      end
    }

    paginated_inbox_rows = WillPaginate::Collection.create(pagination_opts[:page], pagination_opts[:per_page], count) do |pager|
      pager.replace(inbox_rows)
    end

    if request.xhr?
      render :partial => "inbox_row",
        :collection => paginated_inbox_rows, :as => :conversation,
        locals: {
          payments_in_use: @current_community.payments_in_use?
        }
    else
      render locals: {
        inbox_rows: paginated_inbox_rows,
        payments_in_use: @current_community.payments_in_use?
      }
    end
  end

  def transactions

    statuses = %w[free confirmed paid canceled preauthorized rejected
                       payment_intent_requires_action payment_intent_action_expired
                       disputed refunded dismissed]
    @statuses = statuses.map {|status|
      [I18n.t("admin.communities.transactions.status_filter.#{status}"), status]
    }.sort_by{|translation, _status| collator.get_sort_key(translation) }

    params[:page] = 1 unless request.xhr?
    pagination_opts = PaginationViewUtils.parse_pagination_opts(params)
    count = InboxService.transaction_inbox_data_count(@current_user.id, @current_community.id)
    transactional_inbox_rows = transactional_inbox_rows(pagination_opts, count)
    sorted_activity_dates = transactional_inbox_rows.pluck(:last_transition_at)
    pattern = "%#{params[:q]}%"
    if request.xhr?
      unless params[:status].present?
        bucks_histories_in_between_sorted_activity_dates = []
        if sorted_activity_dates.present? && transactional_inbox_rows.next_page.present?
          bucks_histories_in_between_sorted_activity_dates = @current_user.avon_bucks_histories.joins(:person)
                                                                .where("people.given_name LIKE '#{pattern}' OR people.family_name LIKE '#{pattern}' OR people.display_name LIKE '#{pattern}'")
                                                                .where.not(id: session[:avon_bucks_ids])
                                                                .where(transaction_id: nil)
                                                                .where("avon_bucks_histories.created_at <= ? AND avon_bucks_histories.created_at >= ?", 
                                                                    sorted_activity_dates.first.to_date.end_of_day, sorted_activity_dates.last.to_date.beginning_of_day
                                                                )
        else
          bucks_histories_in_between_sorted_activity_dates = @current_user.avon_bucks_histories.joins(:person)
                                                                .where("people.given_name LIKE '#{pattern}' OR people.family_name LIKE '#{pattern}' OR people.display_name LIKE '#{pattern}'")
                                                                .where.not(id: session[:avon_bucks_ids])
                                                                .where(transaction_id: nil)
        end
      else
        bucks_histories_in_between_sorted_activity_dates = []
      end
    else
      unless params[:status].present?
        if sorted_activity_dates.present? && transactional_inbox_rows.next_page.present?
            bucks_histories_in_between_sorted_activity_dates = @current_user.avon_bucks_histories.joins(:person)
                                                                  .where("people.given_name LIKE '#{pattern}' OR people.family_name LIKE '#{pattern}' OR people.display_name LIKE '#{pattern}'")
                                                                  .where(transaction_id: nil)
                                                                  .where("avon_bucks_histories.created_at <= ? AND avon_bucks_histories.created_at >= ?", 
                                                                      sorted_activity_dates.first.to_date.end_of_day, sorted_activity_dates.last.to_date.beginning_of_day
                                                                  )        
        else
          bucks_histories_in_between_sorted_activity_dates = @current_user.avon_bucks_histories.joins(:person)
                                                                .where(transaction_id: nil)
                                                                .where("people.given_name LIKE '#{pattern}' OR people.family_name LIKE '#{pattern}' OR people.display_name LIKE '#{pattern}'")
        end
      else
        bucks_histories_in_between_sorted_activity_dates = []
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

  def sort_column_for_transaction
    column = case params[:sort].to_s
             when "listing"
              "listings.title"
             when "started"
              "created_at"
              when "current_state"
                "current_state"
              else
                "last_transition_at"
              end
    column = "transactions.#{column}" if column.present? && column.index('.').nil?
    column
  end

  def sort_direction
    params[:direction] == 'ASC' ? 'DESC' : 'DESC'
  end

  private

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

  def avon_bucks_histories(pagination_opts)
    @current_user.avon_bucks_histories.order('created_at desc').paginate(page: pagination_opts[:page], per_page: pagination_opts[:per_page])
  end

  def transactional_inbox_rows(pagination_opts, count)
    inbox_rows = InboxService.inbox_data(
      @current_user.id,
      @current_community.id,
      pagination_opts[:limit],
      pagination_opts[:offset],
      params[:status],
      params[:q])

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

end
