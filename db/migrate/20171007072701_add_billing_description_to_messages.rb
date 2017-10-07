class AddBillingDescriptionToMessages < ActiveRecord::Migration[5.0]
  def change
    add_column :messages, :billing_description, :string
  end
end
