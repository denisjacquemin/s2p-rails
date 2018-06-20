class AddSendNotificationByEmailToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :send_notification_by_email, :boolean, default: false
  end
end
