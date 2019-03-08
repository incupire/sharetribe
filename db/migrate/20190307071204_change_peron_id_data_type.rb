class ChangePeronIdDataType < ActiveRecord::Migration[5.1]
  def change
    change_column :avon_bucks_histories, :person_id, :string
  end
end
