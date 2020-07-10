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

require 'rails_helper'

RSpec.describe Rebate, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
