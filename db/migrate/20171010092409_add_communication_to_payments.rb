class AddCommunicationToPayments < ActiveRecord::Migration[5.0]
  def change
    add_column :payments, :communication, :string
  end
end
