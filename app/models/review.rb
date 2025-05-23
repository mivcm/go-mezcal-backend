class Review < ApplicationRecord
  belongs_to :product

  validates :user_name, :rating, :comment, :date, presence: true
  validates :rating, inclusion: { in: 1..5 }
end
