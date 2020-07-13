class AddCouponColumnToTransaction < ActiveRecord::Migration[5.1]
  def change
    add_column :transactions, :rebate_code, :string
    add_column :transactions, :rebate_amount_cents, :integer
  end
end
