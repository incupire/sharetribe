require 'csv'

class Admin::CommunityTransactionsController < Admin::AdminBaseController
  include Collator

  def index
    @selected_left_navi_link = "transactions"
    pagination_opts = PaginationViewUtils.parse_pagination_opts(params)
    statuses = %w[free confirmed paid canceled preauthorized rejected
                       payment_intent_requires_action payment_intent_action_expired
                       disputed refunded dismissed]
    @statuses = statuses.map {|status|
      [I18n.t("admin.communities.transactions.status_filter.#{status}"), status]
    }.sort_by{|translation, _status| collator.get_sort_key(translation) }

    params.permit!
    transactions = if params[:sort].nil? || params[:sort] == "last_activity"
      Transaction.for_community_sorted_by_activity(
        @current_community.id,
        sort_direction,
        pagination_opts[:limit],
        pagination_opts[:offset],
        request.format == :csv,
        params)
    else
      Transaction.for_community_sorted_by_column(
        @current_community.id,
        simple_sort_column(params[:sort]),
        sort_direction,
        pagination_opts[:limit],
        pagination_opts[:offset],
        params)
    end

    for_txn_count = Transaction.exist.by_community(@current_community.id).with_payment_conversation

    if params[:start_date].present? && params[:end_date].present?
      start_date = Date.strptime(params[:start_date],"%m/%d/%Y")
      end_date = Date.strptime(params[:end_date],"%m/%d/%Y")
      for_txn_count = for_txn_count.where(created_at: start_date.beginning_of_day..end_date.end_of_day)
    end

    if params[:status].present?
      for_txn_count = for_txn_count.where(current_state: params[:status])
    end

    transactions = WillPaginate::Collection.create(pagination_opts[:page], pagination_opts[:per_page], for_txn_count.count) do |pager|
      pager.replace(transactions)
    end

    respond_to do |format|
      format.html do
        render("index", {
          locals: {
            community: @current_community,
            transactions: transactions,
          }
        })
      end
      format.csv do
        marketplace_name = if @current_community.use_domain
          @current_community.domain
        else
          @current_community.ident
        end

        self.response.headers["Content-Type"] ||= 'text/csv'
        self.response.headers["Content-Disposition"] = "attachment; filename=#{marketplace_name}-transactions-#{Date.today}.csv"
        self.response.headers["Content-Transfer-Encoding"] = "binary"
        self.response.headers["Last-Modified"] = Time.now.ctime.to_s

        self.response_body = Enumerator.new do |yielder|
          ExportTransactionsJob.generate_csv_for(yielder, transactions)
        end
      end
    end
  end

  def avontage_bucks_transactions
    @selected_left_navi_link = "avontage_bucks_transactions"
    @avontage_bucks_txn = AvonBucksHistory.where(transaction_id: nil).paginate(page: params[:page], per_page: 50).order("#{bucks_sort_column} #{sort_direction}")
  end

  def export
    unless @current_user.is_manager?
      @export_result = ExportTaskResult.create
      params.permit!
      Delayed::Job.enqueue(ExportTransactionsJob.new(@current_user.id, @current_community.id, @export_result.id, params))
    end
    respond_to do |format|
      format.js { render layout: false }
    end
  end

  def export_status
    export_result = ExportTaskResult.where(:token => params[:token]).first
    if export_result
      file_url = export_result.file.present? ? export_result.file.expiring_url(ExportTaskResult::AWS_S3_URL_EXPIRES_SECONDS) : nil
      render json: {token: export_result.token, status: export_result.status, url: file_url}
    else
      render json: {status: 'error'}
    end
  end

  private

  def simple_sort_column(sort_column)
    case sort_column
    when "listing"
      "listings.title"
    when "started"
      "created_at"
    end
  end

  def bucks_sort_column
    if params[:sort].present?
      params[:sort]
    else
      'created_at'
    end
  end

  def sort_direction
    if params[:direction] == "asc"
      "asc"
    else
      "desc" #default
    end
  end
end
