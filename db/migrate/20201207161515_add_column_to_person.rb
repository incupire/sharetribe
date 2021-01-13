class AddColumnToPerson < ActiveRecord::Migration[5.1]
  def change
    add_column :person_categories, :person_id, :string
    add_column :person_categories, :category_id, :integer
  end
end
