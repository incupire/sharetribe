class AddTransactionIdToAvonBucksHistory < ActiveRecord::Migration[5.1]
  def change
    add_column :avon_bucks_histories, :transaction_id, :integer
  end
end
