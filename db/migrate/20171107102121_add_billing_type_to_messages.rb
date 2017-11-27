class AddBillingTypeToMessages < ActiveRecord::Migration[5.0]
  def change
    add_column :messages, :billing_type, :integer, default: '0'
  end
end
