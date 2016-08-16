class AddSkipSendByEmailToMessages < ActiveRecord::Migration[5.0]
  def change
    add_column :messages, :skip_send_by_email, :boolean, default: false
  end
end
