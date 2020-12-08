class AddUpdateMailTitleAndUpdateMailContentToCommunityCustomization < ActiveRecord::Migration[5.1]
  def change
    add_column :community_customizations, :update_mail_title, :string
    add_column :community_customizations, :update_mail_content, :text
  end
end
