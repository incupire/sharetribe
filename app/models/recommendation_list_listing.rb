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

class RecommendationListListing < ApplicationRecord
	belongs_to :listing
	belongs_to :recommendation_list
end
