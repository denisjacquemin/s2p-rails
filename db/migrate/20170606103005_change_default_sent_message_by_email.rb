class ChangeDefaultSentMessageByEmail < ActiveRecord::Migration[5.0]
  def change
    change_column_default :students, :sent_message_by_email, true
  end
end
