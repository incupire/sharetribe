# == Schema Information
#
# Table name: person_categories
#
#  id          :integer          not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  person_id   :string(255)
#  category_id :integer
#
# Indexes
#
#  index_person_categories_on_person_id  (person_id)
#

class PersonCategory < ApplicationRecord
	belongs_to :person
	belongs_to :category
end
