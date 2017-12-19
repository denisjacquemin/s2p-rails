class AddIncludePaymentToMessages < ActiveRecord::Migration[5.0]
  def change
    add_column :messages, :include_payment, :boolean, default: :false
  end
end
