class AddStockToProducts < ActiveRecord::Migration[7.2]
  def change
    add_column :products, :stock, :integer
  end
end
