class AddSendMessageReminderToCommunity < ActiveRecord::Migration[5.1]
  def change
    add_column :communities, :unread_message_reminder_enabled, :boolean, default: false
    add_column :communities, :send_unread_message_reminder_day, :string
  end
end
