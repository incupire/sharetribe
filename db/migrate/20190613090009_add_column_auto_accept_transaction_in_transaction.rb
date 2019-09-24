class AddColumnAutoAcceptTransactionInTransaction < ActiveRecord::Migration[5.1]
  def change
  	add_column :transactions, :auto_accept_transaction, :boolean, default: false
  end
end
