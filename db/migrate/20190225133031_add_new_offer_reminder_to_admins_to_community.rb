class AddNewOfferReminderToAdminsToCommunity < ActiveRecord::Migration[5.1]
  def change
    add_column :communities, :new_offer_reminder_to_admins, :boolean, default: false
  end
end
