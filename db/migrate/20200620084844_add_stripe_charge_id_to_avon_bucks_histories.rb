class AddStripeChargeIdToAvonBucksHistories < ActiveRecord::Migration[5.1]
  def change
    add_column :avon_bucks_histories, :stripe_charge_id, :string
  end
end
