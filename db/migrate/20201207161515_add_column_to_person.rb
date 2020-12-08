class AddColumnToPerson < ActiveRecord::Migration[5.1]
  def change
  	add_reference :person_categories, :person, type: :string, foreign_key: true
  	add_reference :person_categories, :category, type: :int, foreign_key: true
  end
end
