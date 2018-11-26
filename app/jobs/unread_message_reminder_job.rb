class UnreadMessageReminderJob < Struct.new(:message_id, :conversation_id, :community_id)

  include DelayedAirbrakeNotification

  # This before hook should be included in all Jobs to make sure that the service_name is
  # correct as it's stored in the thread and the same thread handles many different communities
  # if the job doesn't have host parameter, should call the method with nil, to set the default service_name
  def before(job)
    # Set the correct service name to thread for I18n to pick it
    ApplicationHelper.store_community_service_name_to_thread_from_community_id(community_id)
  end

  def perform
    message = Message.find(message_id)
    conversation = Conversation.find(conversation_id)
    recipient = message.conversation.other_party(message.sender)
    receiver_participation = conversation.participations.where(person_id: recipient.id).first
    unless receiver_participation.is_read?
      MailCarrier.deliver_now(PersonMailer.send("unread_message_reminder", conversation, message))
      message.push_unread_message_reminder #send email reminders every X days to users for any unread messages
    end
  end

end