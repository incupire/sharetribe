class AddStateCountryToPerson < ActiveRecord::Migration[5.1]
  def change
    add_column :people, :state_country, :string
  end
end
