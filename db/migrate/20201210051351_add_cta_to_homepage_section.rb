class AddCtaToHomepageSection < ActiveRecord::Migration[5.1]
  def change
    add_column :homepage_sections, :cta_link, :text
    add_column :homepage_sections, :cta_text, :text
  end
end
