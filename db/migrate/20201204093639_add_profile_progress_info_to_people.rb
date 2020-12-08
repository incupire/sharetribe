class AddProfileProgressInfoToPeople < ActiveRecord::Migration[5.1]
  def change
  	add_column :people, :profile_progress_info, :string, :default => { contact_info: 0, user_profile: 0, notifications: 0, enable_purchasing: 0, enable_selling: 0}.to_yaml
  end
end
