class AddMinmumAmountToRebate < ActiveRecord::Migration[5.1]
  def change
  	add_column :rebates, :minimum_amount, :float
  end
end
