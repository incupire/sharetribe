# == Schema Information
#
# Table name: person_wish_lists
#
#  id          :integer          not null, primary key
#  person_id   :string(255)
#  category_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class PersonWishList < ApplicationRecord
	belongs_to :wish_list_person, class_name: "Person", foreign_key: :person_id
	belongs_to :wish_list_category, class_name: "Category", foreign_key: :category_id
end
