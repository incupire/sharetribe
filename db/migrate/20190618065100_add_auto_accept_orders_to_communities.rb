class AddAutoAcceptOrdersToCommunities < ActiveRecord::Migration[5.1]
  def change
    add_column :communities, :auto_accept_orders, :boolean, default: false
  end
end
