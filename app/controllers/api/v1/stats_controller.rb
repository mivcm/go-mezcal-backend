class Api::V1::StatsController < ApplicationController
  before_action :authorize_request
  attr_reader :current_user

  def sales
    return render json: { error: 'No autorizado' }, status: :forbidden unless current_user.admin?
    total_sales = Transaction.where(status: 'paid').sum(:amount)
    total_orders = Order.where(status: ['paid', 'completed']).count
    best_selling = Product.joins(:order_items).group('products.id').order('SUM(order_items.quantity) DESC').limit(5).pluck(:name, Arel.sql('SUM(order_items.quantity) as total'))
    render json: {
      total_sales: total_sales,
      total_orders: total_orders,
      best_selling_products: best_selling
    }
  end

  def abandoned_carts
    return render json: { error: 'No autorizado' }, status: :forbidden unless current_user.admin?
    count = Cart.abandoned.count
    render json: { abandoned_carts: count }
  end

  def user_stats
    return render json: { error: 'No autorizado' }, status: :forbidden unless current_user.admin?
    top_users = User.joins(:orders).group('users.id').order('COUNT(orders.id) DESC').limit(5).pluck(:email, 'COUNT(orders.id) as orders_count')
    render json: { top_users: top_users }
  end
end
