class AddSendByEmailAndSendByAppToMessages < ActiveRecord::Migration[5.0]
  def change
    add_column :messages, :send_by_email, :boolean, default: true
    add_column :messages, :send_to_app, :boolean, default: true
  end
end
