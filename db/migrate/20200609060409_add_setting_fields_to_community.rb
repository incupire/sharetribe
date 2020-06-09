class AddSettingFieldsToCommunity < ActiveRecord::Migration[5.1]
  def change
  	add_column :communities, :require_verification_to_post_request, :boolean, default: false
  	add_column :communities, :require_verification_to_send_direct_message, :boolean, default: true
  	add_column :communities, :allow_user_to_post_comment_to_request, :boolean, default: false
  	add_column :communities, :new_request_reminder_to_admins, :boolean, default: true
  end
end
