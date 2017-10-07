class AddMessageIdToPayments < ActiveRecord::Migration[5.0]
  def change
    add_column :payments, :message_id, :integer
  end
end
