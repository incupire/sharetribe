class AddMobileMobileNumberToPeople < ActiveRecord::Migration[5.1]
  def change
    add_column :people, :mobile_number, :string
  end
end
