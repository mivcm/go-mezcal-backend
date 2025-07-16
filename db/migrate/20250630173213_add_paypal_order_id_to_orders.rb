class AddPaypalOrderIdToOrders < ActiveRecord::Migration[7.2]
  def change
    add_column :orders, :paypal_order_id, :string
  end
end
