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
#  index_person_categories_on_category_id  (category_id)
#  index_person_categories_on_person_id    (person_id)
#

require 'rails_helper'

RSpec.describe PersonCategory, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
