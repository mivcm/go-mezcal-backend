class AddPaypalOrderIdToTransactions < ActiveRecord::Migration[7.2]
  def change
    add_column :transactions, :paypal_order_id, :string
  end
end
