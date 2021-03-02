class CreatePersonWishLists < ActiveRecord::Migration[5.1]
  def change
    create_table :person_wish_lists do |t|
      t.string :person_id
      t.integer :category_id

      t.timestamps
    end
  end
end
