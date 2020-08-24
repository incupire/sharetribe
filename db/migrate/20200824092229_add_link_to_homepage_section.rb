class AddLinkToHomepageSection < ActiveRecord::Migration[5.1]
  def change
    add_column :homepage_sections, :testimonial_column1_link, :text
    add_column :homepage_sections, :testimonial_column2_link, :text
    add_column :homepage_sections, :testimonial_column3_link, :text
  end
end
