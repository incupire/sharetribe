# == Schema Information
#
# Table name: rebates
#
#  id         :integer          not null, primary key
#  code       :string(255)
#  amount     :float(24)
#  expire_on  :date
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Rebate < ApplicationRecord
end
