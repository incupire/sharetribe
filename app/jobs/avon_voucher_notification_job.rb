class AvonVoucherNotificationJob < Struct.new(:transaction_id, :community_id)

  include DelayedAirbrakeNotification

  # This before hook should be included in all Jobs to make sure that the service_name is
  # correct as it's stored in the thread and the same thread handles many different communities
  # if the job doesn't have host parameter, should call the method with nil, to set the default service_name
  def before(job)
    # Set the correct service name to thread for I18n to pick it
    ApplicationHelper.store_community_service_name_to_thread_from_community_id(community_id)
  end

  def perform
  	transaction = Transaction.find(transaction_id)
    voucher_url = Rails.application.routes.url_helpers.voucher_show_avontage_voucher_url(id: transaction.id, :host => if Rails.env.eql?("development") then "lvh.me:3000" elsif Rails.env.eql?("staging") then "staging.avontage.com" else "avontage.com" end)
    MailCarrier.deliver_now(TransactionMailer.avon_voucher(transaction))
    
    # SMS Notification
    if transaction.buyer.mobile_number.present?
      SMSNotification.sms_service(
        transaction.buyer.mobile_number, 
        "Hi #{transaction.buyer.given_name} click the #{voucher_url} link to see your Avontage voucher and redeem instructions"
      )
    end
    
    # Push Notification
    PushNotification.send_notification(
      transaction.buyer, 
      "Hi #{transaction.buyer.given_name}. You have a new voucher"
    )
  end
end
