class AddTotalReceivedReview < ActiveRecord::Migration[5.1]
  def change
  	add_column :people, :total_received_review, :integer, default: 0
  end
end
