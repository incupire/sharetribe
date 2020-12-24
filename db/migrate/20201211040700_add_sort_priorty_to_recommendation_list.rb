class AddSortPriortyToRecommendationList < ActiveRecord::Migration[5.1]
  def change
  	add_column :recommendation_lists, :sortpriorty, :integer
  end
end
