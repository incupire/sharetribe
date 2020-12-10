class CreateRecommendationLists < ActiveRecord::Migration[5.1]
  def change
    create_table :recommendation_lists do |t|
      t.string :recommendation_code
      t.string :recommendation_title

      t.timestamps
    end
  end
end
