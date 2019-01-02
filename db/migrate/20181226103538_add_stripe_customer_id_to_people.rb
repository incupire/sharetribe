class AddStripeCustomerIdToPeople < ActiveRecord::Migration[5.1]
  def change
    add_column :people, :stripe_customer_id, :string
  end
end
