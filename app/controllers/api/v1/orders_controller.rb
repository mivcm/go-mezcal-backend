class Api::V1::OrdersController < ApplicationController
  before_action :authorize_request
  attr_reader :current_user

  def index
    orders = current_user.orders.includes(order_items: :product)
    render json: orders.map { |o| order_json(o) }
  end

  def show
    order = current_user.orders.find(params[:id])
    render json: order_json(order)
  end

  def create
    ActiveRecord::Base.transaction do
      order = current_user.orders.create!(
        total: params[:total],
        status: 'pending'
      )
      params[:items].each do |item|
        product = Product.find(item[:product_id])
        order.order_items.create!(product: product, quantity: item[:quantity], price: product.price)
      end
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
        success_url: params[:success_url],
        cancel_url: params[:cancel_url],
        metadata: { order_id: order.id }
      )
      order.update!(stripe_payment_id: session.id)
      # Registrar la transacción
      Transaction.create!(order: order, user: current_user, amount: order.total, status: 'pending', stripe_payment_id: session.id)
      render json: { checkout_url: session.url, order: order_json(order) }, status: :created
    end
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def stripe_webhook
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    event = nil
    begin
      event = Stripe::Webhook.construct_event(
        payload, sig_header, ENV['STRIPE_WEBHOOK_SECRET']
      )
    rescue JSON::ParserError, Stripe::SignatureVerificationError
      return head :bad_request
    end
    if event['type'] == 'checkout.session.completed'
      session = event['data']['object']
      order = Order.find_by(stripe_payment_id: session['id'])
      if order
        order.update(status: 'paid')
        # Actualizar la transacción
        transaction = order.transactions.find_by(stripe_payment_id: session['id'])
        transaction.update(status: 'paid') if transaction
      end
    end
    head :ok
  end

  def complete
    order = Order.find(params[:id])
    if current_user.admin?
      order.complete!
      render json: { order: order_json(order) }
    else
      render json: { error: 'No autorizado' }, status: :forbidden
    end
  end

  def admin_index
    if current_user.admin?
      orders = Order.all_orders_for_admin
      render json: orders.map { |o| order_json(o) }
    else
      render json: { error: 'No autorizado' }, status: :forbidden
    end
  end

  private

  def order_json(order)
    order.as_json(only: [:id, :total, :status, :created_at]).merge(
      user: order.user.as_json(only: [:id, :email]),
      transaction_id: order.transactions.first&.id,
      items: order.order_items.map do |item|
        {
          product: item.product.as_json(only: [:id, :name, :price]),
          quantity: item.quantity,
          price: item.price
        }
      end
    )
  end
end
