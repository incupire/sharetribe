class CreateRebates < ActiveRecord::Migration[5.1]
  def change
    create_table :rebates do |t|
      t.string :code
      t.float :amount
      t.date :expire_on

      t.timestamps
    end
  end
end
