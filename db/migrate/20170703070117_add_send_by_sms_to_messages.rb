class AddSendBySmsToMessages < ActiveRecord::Migration[5.0]
  def change
    add_column :messages, :send_by_sms, :boolean, default: false
  end
end
