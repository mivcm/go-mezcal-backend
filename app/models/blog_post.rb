class BlogPost < ApplicationRecord
  # Usar array nativo de PostgreSQL para tags
  attribute :tags, :string, array: true, default: []
  has_one_attached :cover_image

  before_save :set_slug
  before_save :set_date

  validates :title, presence: true, uniqueness: true
  validates :content, presence: true
  validates :tags, presence: true
  validates :cover_image, presence: true

  def set_slug
    self.slug = title.parameterize
  end

  def set_date
    self.date = Date.today
  end
end
