class CreateFavorites < ActiveRecord::Migration[5.1]
  def change
    create_table :favorites do |t|
      t.integer :listing_id
      t.string :person_id

      t.timestamps
    end
  end
end
