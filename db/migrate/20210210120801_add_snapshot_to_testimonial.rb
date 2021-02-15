class AddSnapshotToTestimonial < ActiveRecord::Migration[5.1]
  def change
  	add_attachment :testimonials, :snapshot
  end
end
