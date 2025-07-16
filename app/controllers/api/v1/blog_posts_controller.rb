class Api::V1::BlogPostsController < ApplicationController
  before_action :authorize_admin, except: [:index, :show]

  def index
    posts = BlogPost.all.order(date: :desc)
    render json: posts.map { |p| blog_post_json(p) }
  end

  def show
    post = BlogPost.find_by!(slug: params[:id])
    render json: blog_post_json(post)
  end

  def create
    post = BlogPost.new(blog_post_params.except(:cover_image))
    if params[:cover_image].present? || (params[:blog_post] && params[:blog_post][:cover_image].present?)
      cover_image = params[:cover_image] || params[:blog_post][:cover_image]
      post.cover_image.attach(cover_image)
    end
    if post.save
      render json: blog_post_json(post), status: :created
    else
      render json: { errors: post.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    post = BlogPost.find(params[:id])
    if post.update(blog_post_params.except(:cover_image))
      if params[:cover_image].present? || (params[:blog_post] && params[:blog_post][:cover_image].present?)
        post.cover_image.purge
        cover_image = params[:cover_image] || params[:blog_post][:cover_image]
        post.cover_image.attach(cover_image)
      end
      render json: blog_post_json(post)
    else
      render json: { errors: post.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    post = BlogPost.find(params[:id])
    post.destroy
    head :no_content
  end

  private

  def blog_post_params
    # Handle both nested and flat parameter structures
    if params[:blog_post]
      params.require(:blog_post).permit(:title, :excerpt, :content, :cover_image, :date, :category, :featured, tags: [])
    else
      # Handle flat parameters
      params.permit(:title, :excerpt, :content, :cover_image, :date, :category, :featured, tags: [])
    end
  end

  def blog_post_json(post)
    post.as_json(only: [:id, :title, :slug, :excerpt, :content, :date, :category, :featured, :tags]).merge(
      cover_image: post.cover_image.attached? ? url_for(post.cover_image) : nil
    )
  end
end
