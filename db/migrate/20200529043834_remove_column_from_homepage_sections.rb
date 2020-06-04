class RemoveColumnFromHomepageSections < ActiveRecord::Migration[5.1]
  def change
  	remove_column :homepage_sections, :testimonial_main_heading_new, :text
  end
end
