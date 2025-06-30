class Api::V1::CartsController < ApplicationController
  before_action :authorize_request
  attr_reader :current_user

  def show
    cart = current_user.carts.where(status: ['active', 'abandoned']).order(created_at: :desc).first
    if cart&.status == 'abandoned'
      cart.update(status: 'active')
    end
    cart ||= current_user.carts.create(status: 'active')
    render json: cart_json(cart)
  end

  def add_item
    cart = current_user.carts.find_or_create_by(status: 'active')
    product = Product.find(params[:product_id])
    item = cart.cart_items.find_or_initialize_by(product: product)
    item.quantity = (item.quantity || 0) + params[:quantity].to_i
    item.save!
    render json: cart_json(cart)
  end

  def remove_item
    cart = current_user.carts.find_by(status: 'active')
    return render json: { error: 'Carrito no encontrado' }, status: :not_found unless cart
    item = cart.cart_items.find_by(product_id: params[:product_id])
    item&.destroy
    render json: cart_json(cart)
  end

  def abandon
    cart = Cart.find(params[:cart_id])
    if cart
      cart.update(status: 'abandoned')
      render json: { message: 'Carrito marcado como abandonado' }
    else
      render json: { error: 'Carrito no encontrado' }, status: :not_found
    end
  end

  def convert_to_order
    cart = current_user.carts.find_by(status: 'active')
    return render json: { error: 'Carrito no encontrado' }, status: :not_found unless cart
    if cart.cart_items.empty?
      return render json: { error: 'El carrito está vacío' }, status: :unprocessable_entity
    end
    ActiveRecord::Base.transaction do
      order = current_user.orders.create!(
        total: cart.cart_items.sum { |item| item.product.price * item.quantity },
        status: 'pending'
      )
      cart.cart_items.each do |item|
        product = item.product
        if product.stock.nil? || product.stock < item.quantity
          raise ActiveRecord::Rollback, "No hay suficiente stock para \\#{product.name}"
        end
        order.order_items.create!(product: product, quantity: item.quantity, price: product.price)
        product.update!(stock: product.stock - item.quantity)
      end
      # Crear sesión de Stripe Checkout
      session = Stripe::Checkout::Session.create(
        payment_method_types: ['card'],
        line_items: order.order_items.map do |item|
          {
            price_data: {
              currency: 'mxn',
              product_data: { name: item.product.name },
              unit_amount: (item.price * 100).to_i
            },
            quantity: item.quantity
          }
        end,
        mode: 'payment',
        success_url: params[:success_url] || 'http://localhost:3000/success',
        cancel_url: params[:cancel_url] || 'http://localhost:3000/cancel',
        metadata: { order_id: order.id }
      )
      order.update!(stripe_payment_id: session.id)
      Transaction.create!(order: order, user: current_user, amount: order.total, status: 'pending', stripe_payment_id: session.id)
      cart.update!(status: 'converted')
      cart.cart_items.destroy_all
      render json: { checkout_url: session.url, order: order_json(order) }, status: :created
    end
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def admin_abandoned
    if current_user.admin?
      carts = Cart.abandoned.includes(:user, cart_items: :product)
      render json: carts.map { |cart| cart_json(cart, include_user: true) }
    else
      render json: { error: 'No autorizado' }, status: :forbidden
    end
  end

  private

  def cart_json(cart, include_user: false)
    base = cart.as_json(only: [:id, :status, :created_at]).merge(
      items: cart.cart_items.map do |item|
        {
          product: item.product.as_json(only: [:id, :name, :price, :stock]).merge(
            image: item.product.images.attached? ? url_for(item.product.images.first) : nil
          ),
          quantity: item.quantity
        }
      end
    )
    if include_user && cart.user
      base[:user] = { email: cart.user.email }
    end
    base
  end

  include Rails.application.routes.url_helpers

  def order_json(order)
    avg_rating = order.order_items.any? ? order.order_items.map { |oi| oi.product.reviews.average(:rating).to_f }.compact.sum / order.order_items.size : nil
    order.as_json(only: [:id, :total, :status, :created_at]).merge(
      items: order.order_items.map do |item|
        {
          product: item.product.as_json(only: [:id, :name, :price]),
          quantity: item.quantity,
          price: item.price
        }
      end,
      rating: avg_rating
    )
  end
end
