class AddBusinessStageToPerson < ActiveRecord::Migration[5.1]
  def change
    add_column :people, :business_stage, :integer
  end
end
