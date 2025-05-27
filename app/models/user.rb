class User < ApplicationRecord
  has_secure_password

  has_many :orders
  has_many :transactions
  has_many :carts

  validates :email, presence: true, uniqueness: true
  validates :password_digest, presence: true

  def admin?
    admin
  end
end
