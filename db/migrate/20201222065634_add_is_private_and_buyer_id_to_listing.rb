class AddIsPrivateAndBuyerIdToListing < ActiveRecord::Migration[5.1]
  def change
    add_column :listings, :is_private, :boolean, default: false
    add_column :listings, :buyer_id, :string
  end
end
