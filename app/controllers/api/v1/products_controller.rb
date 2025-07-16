class Api::V1::ProductsController < ApplicationController
  before_action :set_product, only: %i[show update destroy]
  before_action :authorize_admin, except: %i[index show high_rated_products]


  include Rails.application.routes.url_helpers

  def index
    products = Product.includes(:reviews, images_attachments: :blob)
    render json: products.map { |p| product_json(p) }
  end


  def show
    render json: product_json(@product)
  end

  def create
    product = Product.new(product_params.except(:images))

    if product.save
      attach_images(product) if params[:product][:images].present?

      render json: product_json(product), status: :created
    else
      render json: { errors: product.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @product.update(product_params.except(:images))
      if params[:product][:images].present?
        @product.images.purge # opcional: eliminar imágenes anteriores
        attach_images(@product)
      end

      render json: product_json(@product)
    else
      render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @product.destroy
    head :no_content
  end

  def high_rated_products
    products = Product.includes(:reviews, images_attachments: :blob)
                     .left_joins(:reviews)
                     .group('products.id')
                     .having(
                       'CASE 
                         WHEN COUNT(reviews.id) > 0 
                         THEN AVG(reviews.rating) >= ? AND AVG(reviews.rating) <= ?
                         ELSE products.rating >= ? AND products.rating <= ?
                       END', 
                       4.2, 5.0, 4.2, 5.0
                     )
                     .order(Arel.sql('COALESCE(AVG(reviews.rating), products.rating) DESC'))
    
    render json: products.map { |p| product_json(p) }
  end


  private

  def set_product
    @product = Product.includes(:reviews).find(params[:id])
  end

  def product_params
    params.require(:product).permit(
      :name, :slug, :category, :price, :description, :short_description,
      :abv, :volume, :origin, :featured, :new, :rating, :stock,
      ingredients: [],
      images: []
    )
  end

  def attach_images(product)
    params[:product][:images].each do |image|
      product.images.attach(image)
    end
  end

  def product_json(product)
    avg_rating = product.reviews.any? ? product.reviews.average(:rating).to_f.round(2) : nil
    if avg_rating.nil?
      avg_rating = product.rating
    end
    product.as_json(
      except: [:created_at, :updated_at]
    ).merge(
      images: product.images.map { |img| url_for(img) },
      reviews: product.reviews.map { |r| review_json(r) },
      rating: avg_rating
    )
  end

  def review_json(review)
    review.as_json(except: [:created_at, :updated_at, :product_id])
  end
end
