class RemoveStripePaymentIdFromOrders < ActiveRecord::Migration[7.2]
  def change
    remove_column :orders, :stripe_payment_id, :string
  end
end
