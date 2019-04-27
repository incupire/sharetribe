class AddOperatorIdToAvonBucksHistories < ActiveRecord::Migration[5.1]
  def change
    add_column :avon_bucks_histories, :operator_id, :string
  end
end
