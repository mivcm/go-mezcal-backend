class BlogPost < ApplicationRecord
  serialize :tags, Array
  has_one_attached :cover_image
end
