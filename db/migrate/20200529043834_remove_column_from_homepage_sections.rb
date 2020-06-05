class RemoveColumnFromHomepageSections < ActiveRecord::Migration[5.1]
  def change
    if column_exists? :homepage_sections, :testimonial_main_heading_new
      remove_column :homepage_sections, :testimonial_main_heading_new, :text
    end
  end
end
