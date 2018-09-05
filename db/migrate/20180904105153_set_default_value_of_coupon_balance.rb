class SetDefaultValueOfCouponBalance < ActiveRecord::Migration[5.1]
  def change
    change_column_default :people, :coupon_balance_cents, 0
  end
end
