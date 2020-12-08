class AddDisplayInUserProfileToCategory < ActiveRecord::Migration[5.1]
  def change
    add_column :categories, :display_in_user_profile, :boolean, default: false
  end
end
