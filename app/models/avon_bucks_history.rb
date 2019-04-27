# == Schema Information
#
# Table name: avon_bucks_histories
#
#  id                      :integer          not null, primary key
#  amount_cents            :integer
#  operation               :string(255)
#  remaining_balance_cents :integer
#  person_id               :string(255)
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  currency                :string(255)
#  transaction_id          :integer
#  operator_id             :string(255)
#

class AvonBucksHistory < ApplicationRecord
  VALID_OPERATIONS = ["added", "deducted"]
  validates_inclusion_of :operation, :in => VALID_OPERATIONS
  
  belongs_to :person
  belongs_to :bucks_transaction, class_name: "Transaction", foreign_key: "transaction_id" , optional: true
  belongs_to :operator, class_name: "Person", foreign_key: "operator_id", optional: true
  
  monetize :amount_cents, :allow_nil => true, with_model_currency: :currency
  monetize :remaining_balance_cents, :allow_nil => true, with_model_currency: :currency
end
