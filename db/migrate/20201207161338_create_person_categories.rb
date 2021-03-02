class CreatePersonCategories < ActiveRecord::Migration[5.1]
  def change
    create_table :person_categories do |t|
    	
      t.timestamps
    end
  end
end
