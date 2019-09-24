class AddHintColumnInCustomField < ActiveRecord::Migration[5.1]
  def change
  	add_column :custom_fields, :hint, :string
  end
end
