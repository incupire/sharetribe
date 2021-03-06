# == Schema Information
#
# Table name: messages
#
#  id              :integer          not null, primary key
#  sender_id       :string(255)
#  content         :text(65535)
#  created_at      :datetime
#  updated_at      :datetime
#  conversation_id :integer
#
# Indexes
#
#  index_messages_on_conversation_id  (conversation_id)
#

class Message < ApplicationRecord

  after_save :update_conversation_read_status
  after_save :push_unread_message_reminder

  belongs_to :sender, :class_name => "Person"
  belongs_to :conversation

  validates_presence_of :sender_id
  validates_presence_of :content

  scope :latest_for_conversation, -> {
    joins('LEFT JOIN messages m2 ON
          (messages.conversation_id = m2.conversation_id AND messages.created_at < m2.created_at)')
    .where('m2.created_at IS NULL')
  }
  scope :by_converation_ids, -> (converation_ids) { where(conversation_id: converation_ids) }
  scope :latest, -> { order('messages.created_at DESC') }

  def update_conversation_read_status
    conversation.update_attribute(:last_message_at, created_at)
    conversation.participations.each do |p|
      last_at = p.person.eql?(sender) ? :last_sent_at : :last_received_at
      p.update_attributes({ :is_read => p.person.eql?(sender), last_at => created_at})
    end
  end

  def push_unread_message_reminder
    community = conversation.community
    # if self.conversation.tx.present?
    #   transaction = self.conversation.tx
    #   transaction.push_unread_message_reminder
    # else
    if community.unread_message_reminder_enabled? && community.send_unread_message_reminder_day.present?
      Delayed::Job.enqueue(UnreadMessageReminderJob.new(self.id, conversation_id, conversation.community_id), priority: 9, :run_at => (Date.today + community.send_unread_message_reminder_day.to_i.days).beginning_of_day + 4.hours)
    end
    #end
  end
end
