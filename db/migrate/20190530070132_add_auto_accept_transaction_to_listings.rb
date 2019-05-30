class AddAutoAcceptTransactionToListings < ActiveRecord::Migration[5.1]
  def change
    add_column :listings, :auto_accept_transaction, :boolean, default: false
  end
end
