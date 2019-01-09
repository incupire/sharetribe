class AddAvonCommissionChargeIdToTransaction < ActiveRecord::Migration[5.1]
  def change
    add_column :transactions, :avon_commission_charge_id, :string
  end
end
