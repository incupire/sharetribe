# == Schema Information
#
# Table name: favorites
#
#  id         :integer          not null, primary key
#  listing_id :integer
#  person_id  :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe Favorite, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
