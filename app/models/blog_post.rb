class BlogPost < ApplicationRecord
  # Usar array nativo de PostgreSQL para tags
  attribute :tags, :string, array: true, default: []
  has_one_attached :cover_image
end
