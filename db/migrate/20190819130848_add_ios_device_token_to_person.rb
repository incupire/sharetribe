class AddIosDeviceTokenToPerson < ActiveRecord::Migration[5.1]
  def change
    add_column :people, :ios_device_token, :string
  end
end
