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

class Favorite < ApplicationRecord
  belongs_to :listing
  belongs_to :person 
end
