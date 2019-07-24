class AddDeviceTokenToPeople < ActiveRecord::Migration[5.1]
  def change
    add_column :people, :android_device_token, :string
  end
end
