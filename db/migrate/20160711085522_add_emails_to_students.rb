class AddEmailsToStudents < ActiveRecord::Migration[5.0]
  def change
    add_column :students, :emails, :string
    add_column :students, :sent_message_by_email, :boolean
  end
end
