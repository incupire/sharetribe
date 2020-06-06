class AddAutoCompleteOrdersToCommunity < ActiveRecord::Migration[5.1]
  def change
    add_column :communities, :auto_complete_orders, :boolean, default: false
  end
end
