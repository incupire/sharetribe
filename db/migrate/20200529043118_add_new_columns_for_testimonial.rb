class AddNewColumnsForTestimonial < ActiveRecord::Migration[5.1]
  def change
    add_column :homepage_sections, :testimonial_column1_content, :text
    add_column :homepage_sections, :testimonial_column1_star_count, :float
    add_column :homepage_sections, :testimonial_column2_name, :text
    add_column :homepage_sections, :testimonial_column2_work, :text
    add_column :homepage_sections, :testimonial_column2_type, :text
    add_column :homepage_sections, :testimonial_column2_content, :text
    add_column :homepage_sections, :testimonial_column2_star_count, :float
    add_column :homepage_sections, :testimonial_column3_name, :text
    add_column :homepage_sections, :testimonial_column3_work, :text
    add_column :homepage_sections, :testimonial_column3_type, :text
    add_column :homepage_sections, :testimonial_column3_content, :text
    add_column :homepage_sections, :testimonial_column3_star_count, :float
  end
end
