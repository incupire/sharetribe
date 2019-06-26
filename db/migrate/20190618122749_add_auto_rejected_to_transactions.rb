class AddAutoRejectedToTransactions < ActiveRecord::Migration[5.1]
  def change
    add_column :transactions, :auto_rejected, :boolean, default: false
  end
end
