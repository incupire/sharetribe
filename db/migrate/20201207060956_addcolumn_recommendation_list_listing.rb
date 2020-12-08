class AddcolumnRecommendationListListing < ActiveRecord::Migration[5.1]
  def change
  	add_reference :recommendation_list_listings, :recommendation_list, index: true
  	add_reference :recommendation_list_listings, :listing, index: true
  end
end
