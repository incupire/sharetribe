class AddCouponBalanceToPeople < ActiveRecord::Migration[5.1]
  def change
    add_column :people, :coupon_balance_cents, :integer
  end
end
