class AddGraphicImageToCommunity < ActiveRecord::Migration[5.1]
  def up
    add_attachment :communities, :reload_page_graphic
    add_attachment :communities, :homepage_graphic
    add_column :communities, :homepage_graphic_url, :string
  end

  def down
    remove_attachment :communities, :reload_page_graphic
    remove_attachment :communities, :homepage_graphic
    remove_column :communities, :homepage_graphic_url, :string
  end
end
