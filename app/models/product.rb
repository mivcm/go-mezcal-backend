class Product < ApplicationRecord
  has_many :reviews, dependent: :destroy

  has_many_attached :images

  CATEGORIES = %w[joven reposado anejo ancestral].freeze

  validates :name, :slug, :category, :price, :description, :short_description,
            :abv, :volume, :origin, presence: true

  validates :category, inclusion: { in: CATEGORIES }
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :abv, :volume, numericality: true

  attribute :ingredients, :jsonb, default: []
end
