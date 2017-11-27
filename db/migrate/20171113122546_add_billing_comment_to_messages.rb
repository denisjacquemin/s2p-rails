class AddBillingCommentToMessages < ActiveRecord::Migration[5.0]
  def change
    add_column :messages, :billing_comment, :text
  end
end
