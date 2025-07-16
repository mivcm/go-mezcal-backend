class SiteSetting < ApplicationRecord
    has_one_attached :image
    validates :key, presence: true, uniqueness: true
end
