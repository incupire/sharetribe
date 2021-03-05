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

class PersonCategory < ApplicationRecord
	belongs_to :person
	belongs_to :category
end
