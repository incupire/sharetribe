# == Schema Information
#
# Table name: recommendation_lists
#
#  id                   :integer          not null, primary key
#  recommendation_code  :string(255)
#  recommendation_title :string(255)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  active               :boolean          default(FALSE)
#  sortpriorty          :integer
#

require 'rails_helper'

RSpec.describe RecommendationList, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
