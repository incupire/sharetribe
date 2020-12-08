class AddHomepageGraphicToCommunity < ActiveRecord::Migration[5.1]
  def change
  	add_attachment :communities, :homepage_graphic2
  	add_column :communities, :homepage_graphic_url2, :string
  end
end
