class AddcolumnToRecommendedList < ActiveRecord::Migration[5.1]
  def change
  	add_column :recommendation_lists, :active, :boolean, default: false
  end
end
