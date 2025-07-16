class CreateContactMessages < ActiveRecord::Migration[7.2]
  def change
    create_table :contact_messages do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :phone
      t.string :subject, null: false
      t.text :message, null: false
      t.boolean :read, default: false, null: false

      t.timestamps
    end

    add_index :contact_messages, :email
    add_index :contact_messages, :created_at
    add_index :contact_messages, :read
  end
end
