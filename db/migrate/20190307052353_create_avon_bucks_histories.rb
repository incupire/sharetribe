class CreateAvonBucksHistories < ActiveRecord::Migration[5.1]
  def change
    create_table :avon_bucks_histories do |t|
      t.integer :amount_cents
      t.string :operation
      t.integer :remaining_balance_cents
      t.integer :person_id

      t.timestamps
    end
  end
end
