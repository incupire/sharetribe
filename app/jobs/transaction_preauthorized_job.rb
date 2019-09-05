class TransactionPreauthorizedJob < Struct.new(:transaction_id)

  include DelayedAirbrakeNotification

  # This before hook should be included in all Jobs to make sure that the service_name is
  # correct as it's stored in the thread and the same thread handles many different communities
  # if the job doesn't have host parameter, should call the method with nil, to set the default service_name
  def before(job)
    # Set the correct service name to thread for I18n to pick it
    transaction = Transaction.find(transaction_id)
    ApplicationHelper.store_community_service_name_to_thread_from_community_id(transaction.community.id)
  end

  def perform
    transaction = Transaction.find(transaction_id)
    transaction_url = Rails.application.routes.url_helpers.person_transaction_url(person_id: transaction.author.id, id: transaction.id, :host => Rails.env.eql?("development") ? "lvh.me:3000" : "avontage.com" )
    MailCarrier.deliver_now(TransactionMailer.transaction_preauthorized(transaction))
    if transaction.author.mobile_number.present?
      SMSNotification.sms_service(transaction.author.mobile_number, "Hi #{transaction.author.given_name},\n Congratulations! #{transaction.buyer.given_name} just purchased your offer #{transaction.listing.title}. Click here to respond ASAP #{transaction_url}")
    end
  end
end
