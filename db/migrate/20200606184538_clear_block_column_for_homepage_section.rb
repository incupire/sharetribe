class ClearBlockColumnForHomepageSection < ActiveRecord::Migration[5.1]
  def change
  	if column_exists? :homepage_sections, :testimonial_main_heading
      remove_column :homepage_sections, :testimonial_main_heading, :string
    end
    if column_exists? :homepage_sections, :testimonial_column1_name
    	remove_column :homepage_sections, :testimonial_column1_name, :string
    end
    if column_exists? :homepage_sections, :testimonial_column1_work
    	remove_column :homepage_sections, :testimonial_column1_work, :string
    end
    if column_exists? :homepage_sections, :testimonial_column1_type
    	remove_column :homepage_sections, :testimonial_column1_type, :string
    end
    add_column :homepage_sections, :testimonial_main_heading, :string
    add_column :homepage_sections, :testimonial_column1_name, :string
    add_column :homepage_sections, :testimonial_column1_work, :string
    add_column :homepage_sections, :testimonial_column1_type, :string
  end
end
