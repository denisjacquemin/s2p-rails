class AddReasonToEmailRecipients < ActiveRecord::Migration[5.2]
  def change
    add_column :email_recipients, :reason, :string
  end
end
