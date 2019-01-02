class AddAvonBucksCommissionToTransactions < ActiveRecord::Migration[5.1]
  def change
    add_column :transactions, :avon_commission_cents, :integer
    add_column :transactions, :avon_commission_currency, :string
  end
end
