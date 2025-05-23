class Order < ApplicationRecord
  enum status: { pending: 'pending', paid: 'paid', completed: 'completed', cancelled: 'cancelled' }

  belongs_to :user
  has_many :order_items, dependent: :destroy
  has_many :transactions

  # Método para marcar la orden como completada por el admin
  def complete!
    update(status: 'completed')
  end

  def self.all_orders_for_admin
    Order.includes(:user, :order_items, :transactions).order(created_at: :desc)
  end
end
