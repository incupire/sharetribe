class AddFavoritesCountToListingAndPerson < ActiveRecord::Migration[5.1]
  def change
    add_column :people, :favorites_count, :integer, default: 0
    add_column :listings, :favorites_count, :integer, default: 0
  end
end
