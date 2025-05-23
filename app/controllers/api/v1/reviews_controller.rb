class Api::V1::ReviewsController < ApplicationController
  before_action :authorize_request, only: %i[create update destroy]
  before_action :set_product
  before_action :set_review, only: %i[show update destroy]

  def index
    render json: @product.reviews.map { |r| review_json(r) }
  end

  def show
    render json: review_json(@review)
  end

  def create
    review = @product.reviews.build(review_params)
    if review.save
      render json: review_json(review), status: :created
    else
      render json: { errors: review.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @review.update(review_params)
      render json: review_json(@review)
    else
      render json: { errors: @review.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @review.destroy
    head :no_content
  end

  private

  def set_product
    @product = Product.find(params[:product_id])
  end

  def set_review
    @review = @product.reviews.find(params[:id])
  end

  def review_params
    params.require(:review).permit(:user_name, :user_image, :rating, :comment, :date)
  end

  def review_json(review)
    review.as_json(except: [:created_at, :updated_at, :product_id])
  end
end
