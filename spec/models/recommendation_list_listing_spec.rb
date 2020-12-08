# == Schema Information
#
# Table name: recommendation_list_listings
#
#  id                     :integer          not null, primary key
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  recommendation_list_id :integer
#  listing_id             :integer
#
# Indexes
#
#  index_recommendation_list_listings_on_listing_id              (listing_id)
#  index_recommendation_list_listings_on_recommendation_list_id  (recommendation_list_id)
#

require 'rails_helper'

RSpec.describe RecommendationListListing, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
