class AddTagsToListingAndPerson < ActiveRecord::Migration[5.1]
  def change
    add_column :listings, :tags, :text
    add_column :people, :tags, :text
  end
end
