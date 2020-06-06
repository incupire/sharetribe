class AddTestimonialMainHeadingToHomepageSections < ActiveRecord::Migration[5.1]
  def change
    unless column_exists? :homepage_sections, :testimonial_main_heading
      add_column :homepage_sections, :testimonial_main_heading, :string
    end
  end
end
