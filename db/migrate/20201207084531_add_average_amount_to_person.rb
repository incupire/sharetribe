class AddAverageAmountToPerson < ActiveRecord::Migration[5.1]
  def change
    add_column :people, :average_amount, :integer
  end
end
