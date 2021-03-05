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

class RecommendationList < ApplicationRecord
  has_many :recommendation_list_listings
  has_many :listings, through: :recommendation_list_listings
  
  default_scope { order(sortpriorty: :asc) }
end
