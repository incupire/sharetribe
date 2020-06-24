class AddIsManagerToPerson < ActiveRecord::Migration[5.1]
  def change
    add_column :people, :is_manager, :boolean, default: false
  end
end
