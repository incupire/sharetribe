class AddCustomOfferTextToCommunityCustomization < ActiveRecord::Migration[5.1]
  def change
    add_column :community_customizations, :custom_offer_text, :text
  end
end
