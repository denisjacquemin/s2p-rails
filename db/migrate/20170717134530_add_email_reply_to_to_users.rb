class AddEmailReplyToToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :email_reply_to, :string, default: ""
  end
end
