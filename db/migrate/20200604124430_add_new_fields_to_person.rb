class AddNewFieldsToPerson < ActiveRecord::Migration[5.1]
  def change
    add_column :people, :business_name, :string
    add_column :people, :website_name, :string
    add_column :people, :physical_location, :string
    add_column :people, :community_description_experience, :text
    add_column :people, :facebook_link, :string
    add_column :people, :instagram_link, :string
    add_column :people, :linkedin_link, :string
    add_column :people, :twitter_link, :string
  end
end
