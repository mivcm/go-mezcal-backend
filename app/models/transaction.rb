class Transaction < ApplicationRecord
  belongs_to :order
  belongs_to :user
  validates :amount, :status, :stripe_payment_id, presence: true
end
