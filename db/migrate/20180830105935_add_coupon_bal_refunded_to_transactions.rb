class AddCouponBalRefundedToTransactions < ActiveRecord::Migration[5.1]
  def change
    add_column :transactions, :coupon_bal_refunded, :boolean, default: false
  end
end
