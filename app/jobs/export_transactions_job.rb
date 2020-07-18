require 'csv'
class ExportTransactionsJob < Struct.new(:current_user_id, :community_id, :export_task_id, :params)
  include DelayedAirbrakeNotification

  # This before hook should be included in all Jobs to make sure that the service_name is
  # correct as it's stored in the thread and the same thread handles many different communities
  # if the job doesn't have host parameter, should call the method with nil, to set the default service_name
  def before(job)
    # Set the correct service name to thread for I18n to pick it
    ApplicationHelper.store_community_service_name_to_thread_from_community_id(community_id)
  end

  def perform
    community = Community.find(community_id)
    export_task = ExportTaskResult.find(export_task_id)
    export_task.update_attributes(status: 'started')

    conversations = Transaction.for_community_sorted_by_activity(community.id, 'desc', nil, nil, true, nil)

    if params[:start_date].present? && params[:end_date].present?
      start_date = Date.strptime(params[:start_date],"%m/%d/%Y")
      end_date = Date.strptime(params[:end_date],"%m/%d/%Y")
      conversations = conversations.where(created_at: start_date.beginning_of_day..end_date.end_of_day)
    end

    if params[:status].present? && ['confirmed', 'preauthorized'].include?(params[:status])
      conversations = conversations.where(current_state: params[:status])
    end

    if params[:status].present? && ['confirmed', 'preauthorized'].include?(params[:status])
      conversations = conversations.where(current_state: params[:status])
    elsif params[:status].eql?('unresponded')
      conversations = conversations.where(current_state: 'free')
      txns = []
      conversations.each do |txn|
        txns << txn.id if txn.conversation.present? && txn.conversation.messages.size == 1
      end
      conversations = conversations.where(id: txns)
    end

    csv_rows = []
    ExportTransactionsJob.generate_csv_for(csv_rows, conversations)
    csv_content = csv_rows.join("")
    marketplace_name = community.use_domain ? community.domain : community.ident
    filename = "#{marketplace_name}-transactions-#{Time.zone.today}-#{export_task.token}.csv"
    export_task.original_filename = filename
    export_task.original_extname = File.extname(filename).delete('.')
    export_task.update_attributes(status: 'finished', file: FakeFileIO.new(filename, csv_content))
  end

  class FakeFileIO < StringIO
    attr_reader :original_filename
    attr_reader :path

    def initialize(filename, content)
      super(content)
      @original_filename = File.basename(filename)
      @path = File.path(filename)
    end
  end

  class << self
    def generate_csv_for(yielder, transactions)
     # first line is column names
     yielder << %w{
       transaction_id
       listing_id
       listing_title
       status
       currency
       sum
       started_at
       last_activity_at
       starter_username
       other_party_username,
       starter_coupon_balance,
       author_coupon_balnce
     }.to_csv(force_quotes: true)
     transactions.each do |transaction|
       next unless transaction.listing
       yielder << [
         transaction.id,
         transaction.listing ? transaction.listing.id : "N/A",
         transaction.listing ? transaction.listing_title : "N/A",
         transaction.status,
         transaction.payment_total.is_a?(Money) ? transaction.payment_total.currency : "N/A",
         transaction.payment_total,
         transaction.created_at,
         transaction.last_activity,
         transaction.starter ? transaction.starter.username : "DELETED",
         transaction.author ? transaction.author.username : "DELETED",
         (transaction&.starter.present? && transaction.starter&.coupon_balance.present?) ? (transaction.starter&.coupon_balance_cents/100).to_f : "",
         (transaction.author.present? && transaction.author&.coupon_balance.present?) ? (transaction.author&.coupon_balance_cents/100).to_f : ""
       ].to_csv(force_quotes: true)
     end
    end
  end
end
