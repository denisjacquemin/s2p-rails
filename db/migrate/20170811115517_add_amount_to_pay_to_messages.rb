class AddAmountToPayToMessages < ActiveRecord::Migration[5.0]
  def change
    add_monetize :messages, :amount_to_pay
  end
end
