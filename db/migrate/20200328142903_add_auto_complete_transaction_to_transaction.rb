class AddAutoCompleteTransactionToTransaction < ActiveRecord::Migration[5.1]
  def change
    add_column :transactions, :auto_complete_transaction, :boolean, default: false
  end
end
