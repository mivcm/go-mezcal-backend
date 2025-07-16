class Transaction < ApplicationRecord
  belongs_to :order
  belongs_to :user
  validates :amount, :status, :paypal_order_id, presence: true
end
