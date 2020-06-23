class AddNewFieldToStripeAccount < ActiveRecord::Migration[5.1]
  def change
  	add_column :stripe_accounts, :ein_code, :string
  end
end
