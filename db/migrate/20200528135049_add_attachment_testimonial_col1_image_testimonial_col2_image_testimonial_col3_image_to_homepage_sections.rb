class AddAttachmentTestimonialCol1ImageTestimonialCol2ImageTestimonialCol3ImageToHomepageSections < ActiveRecord::Migration[5.1]
  def self.up
    change_table :homepage_sections do |t|
      t.attachment :testimonial_col1_image
      t.attachment :testimonial_col2_image
      t.attachment :testimonial_col3_image
    end
  end

  def self.down
    remove_attachment :homepage_sections, :testimonial_col1_image
    remove_attachment :homepage_sections, :testimonial_col2_image
    remove_attachment :homepage_sections, :testimonial_col3_image
  end
end
