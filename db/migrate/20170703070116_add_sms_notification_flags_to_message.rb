class AddSmsNotificationFlagsToMessage < ActiveRecord::Migration[5.0]
  def change
    add_column :messages, :wfa_sms_sent, :boolean, default: false
    add_column :messages, :aa_sms_sent, :boolean, default: false
    add_column :messages, :ar_sms_sent, :boolean, default: false
  end
end
