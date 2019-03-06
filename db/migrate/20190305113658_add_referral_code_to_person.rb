class AddReferralCodeToPerson < ActiveRecord::Migration[5.1]
  def change
    add_column :people, :referral_code, :string
  end
end
