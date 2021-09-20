class AddSendNotificationForApprovalAndRefuseToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :send_notification_for_approval_and_refuse, :boolean, default:false
  end
end
