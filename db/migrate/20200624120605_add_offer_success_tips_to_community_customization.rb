class AddOfferSuccessTipsToCommunityCustomization < ActiveRecord::Migration[5.1]
  def change
    add_column :community_customizations, :offer_success_tips, :text
  end
end
