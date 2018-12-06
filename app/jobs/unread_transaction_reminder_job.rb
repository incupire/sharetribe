class UnreadTransactionReminderJob < Struct.new(:tx_id, :conversation_id, :community_id)

  include DelayedAirbrakeNotification

  # This before hook should be included in all Jobs to make sure that the service_name is
  # correct as it's stored in the thread and the same thread handles many different communities
  # if the job doesn't have host parameter, should call the method with nil, to set the default service_name
  def before(job)
    # Set the correct service name to thread for I18n to pick it
    ApplicationHelper.store_community_service_name_to_thread_from_community_id(community_id)
  end

  def perform
    tx = Transaction.find(tx_id)
    community = Community.find(community_id)
    starter = tx.starter
    author = tx.author

    count_for_starter = InboxService.inbox_data_count(starter.id, community.id)
    count_for_author = InboxService.inbox_data_count(author.id, community.id)

    starter_inbox_rows = InboxService.inbox_data(
      starter.id,
      community.id,
      count_for_starter,
      0)  

    author_inbox_rows = InboxService.inbox_data(
      author.id,
      community.id,
      count_for_author,
      0)
    
    tx_starter_inbox = starter_inbox_rows.select{|inbox| inbox[:type].eql?(:transaction) && inbox[:transaction_id].eql?(tx.id)}.first     
    tx_author_inbox = author_inbox_rows.select{|inbox| inbox[:type].eql?(:transaction) && inbox[:transaction_id].eql?(tx.id)}.first
    if tx_starter_inbox[:should_notify]
      MailCarrier.deliver_now(PersonMailer.send("unread_transaction_reminder", tx, tx.conversation, starter))
    elsif tx_author_inbox[:should_notify]
      MailCarrier.deliver_now(PersonMailer.send("unread_transaction_reminder", tx, tx.conversation, author))
    end

    tx.push_unread_message_reminder
  end
end
