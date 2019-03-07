class AddCurrencyToAvonBucksHistories < ActiveRecord::Migration[5.1]
  def change
    add_column :avon_bucks_histories, :currency, :string
  end
end
