class AddBillingDueDateToMessages < ActiveRecord::Migration[5.0]
  def change
    add_column :messages, :billing_due_date, :string
  end
end
