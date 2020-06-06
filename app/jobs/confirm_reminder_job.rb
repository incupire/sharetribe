class ConfirmReminderJob < Struct.new(:conversation_id, :recipient_id, :community_id, :days_to_cancel)

  include DelayedAirbrakeNotification

  # This before hook should be included in all Jobs to make sure that the service_name is
  # correct as it's stored in the thread and the same thread handles many different communities
  # if the job doesn't have host parameter, should call the method with nil, to set the default service_name
  def before(job)
    # Set the correct service name to thread for I18n to pick it
    ApplicationHelper.store_community_service_name_to_thread_from_community_id(community_id)
  end

  def perform
    return if Maybe(::PlanService::API::Api.plans.get_current(community_id: community_id).data)[:expired].or_else(false)

    transaction = Transaction.find(conversation_id)
    community = Community.find(community_id)
    if transaction.status.eql?("paid")
      MailCarrier.deliver_now(PersonMailer.send("confirm_reminder", transaction, transaction.buyer, community, days_to_cancel))
      
      if transaction.buyer.should_receive_sms?("sms_remainder_to_mark_complete")
        # SMS Notification
        SMSNotification.sms_service(
          transaction.buyer.mobile_number, 
          sms_body(transaction, community)
        )
      end

      # Push Notification
      PushNotification.send_notification(
        transaction.buyer, 
        sms_body(transaction, community)
      )
    end
  end

  private

  def sms_body(conversation, community)
    conversation_url = Rails.application.routes.url_helpers.person_message_url(person_id: conversation.buyer, id: conversation.id, :host => if Rails.env.eql?("development") then "lvh.me:3000" elsif Rails.env.eql?("staging") then "staging.avontage.com" else "avontage.com" end )
    message = I18n.t("sms.confirm_reminder.you_have_not_yet_confirmed_or_canceled_request",
              :date => ApplicationController.helpers.time_ago(conversation.created_at.to_date),
              :other_party_full_name => conversation.seller.name(conversation.community),
              :other_party_given_name => conversation.seller.name_or_username
              ).html_safe

    return "#{message} \n #{conversation_url}"
  end

end
