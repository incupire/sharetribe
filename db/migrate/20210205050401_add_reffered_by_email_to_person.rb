class AddRefferedByEmailToPerson < ActiveRecord::Migration[5.1]
  def change
    add_column :people, :reffered_by_email, :string
    add_column :people, :reffered_by_socialmedia, :integer
    add_column :people, :reffered_by_other, :string
  end
end
