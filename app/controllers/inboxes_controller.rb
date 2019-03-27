class InboxesController < ApplicationController
  include MoneyRails::ActionViewExtension

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
      pagination_opts[:offset])

    count = InboxService.inbox_data_count(@current_user.id, @current_community.id)

    inbox_rows = inbox_rows.map { |inbox_row|
      extended_inbox = inbox_row.merge(
        path: path_to_conversation_or_transaction(inbox_row),
        last_activity_ago: time_ago(inbox_row[:last_activity_at]),
        title: inbox_title(inbox_row, inbox_payment(inbox_row))
      )
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

    # We use pageless scroll, so the page should be always the first one (1) when request was not AJAX request
    params[:page] = 1 unless request.xhr?
    pagination_opts = PaginationViewUtils.parse_pagination_opts(params)

    avon_bucks_histories = @current_user.avon_bucks_histories.order('created_at desc').paginate(page: params[:page], per_page: pagination_opts[:per_page])

    inbox_rows = InboxService.inbox_data(@current_user.id, @current_community.id, pagination_opts[:limit], pagination_opts[:offset])

    # Transactions Messages & Management are on aseparated from Inbox messages 
    inbox_rows = inbox_rows.select{|row| row[:type].eql?(:transaction)} 

    count = inbox_rows.count 

    inbox_rows = inbox_rows.map { |inbox_row|  
      inbox_row.merge(  
        path: path_to_conversation_or_transaction(inbox_row), 
        last_activity_ago: time_ago(inbox_row[:last_activity_at]),  
        title: inbox_title(inbox_row, inbox_payment(inbox_row)),  
        listing_url: listing_path(id: inbox_row[:listing_id]) 
      )
    } 

    paginated_inbox_rows = WillPaginate::Collection.create(pagination_opts[:page], pagination_opts[:per_page], count) do |pager| 
      pager.replace(inbox_rows) 
    end

    if request.xhr?
      if params[:type].eql?("avon_bucks_history")
        render :partial => "transaction_row",
          :collection => avon_bucks_histories, :as => :history
      else
        render :partial => "inbox_row",
          :collection => paginated_inbox_rows, :as => :conversation,
          locals: {
            payments_in_use: @current_community.payments_in_use?
          }
      end
    else
      render locals: { 
        history_rows: avon_bucks_histories,
        inbox_rows: paginated_inbox_rows,
        payments_in_use: @current_community.payments_in_use?
      }
    end
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

end
