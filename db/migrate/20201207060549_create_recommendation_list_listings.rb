class CreateRecommendationListListings < ActiveRecord::Migration[5.1]
  def change
    create_table :recommendation_list_listings do |t|

      t.timestamps
    end
  end
end
