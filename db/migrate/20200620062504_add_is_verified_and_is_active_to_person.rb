class AddIsVerifiedAndIsActiveToPerson < ActiveRecord::Migration[5.1]
  def change
    add_column :people, :is_verified, :boolean, default: false
    add_column :people, :is_active, :boolean, default: true
    add_column :people, :user_level, :integer
  end
end
