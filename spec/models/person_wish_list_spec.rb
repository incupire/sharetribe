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

require 'rails_helper'

RSpec.describe PersonWishList, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
