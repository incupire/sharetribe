class AddAutoCompleteTransactionToListing < ActiveRecord::Migration[5.1]
  def change
    add_column :listings, :auto_complete_transaction, :boolean, default: false
  end
end
