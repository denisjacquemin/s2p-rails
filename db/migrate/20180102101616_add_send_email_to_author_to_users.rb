class AddSendEmailToAuthorToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :send_email_to_author, :boolean, default: :true
  end
end
