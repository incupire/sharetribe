class AddLinkedinIdToPeople < ActiveRecord::Migration[5.1]
  def change
    add_column :people, :linkedin_id, :string
  end
end
