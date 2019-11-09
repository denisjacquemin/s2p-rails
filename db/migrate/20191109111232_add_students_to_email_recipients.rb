class AddStudentsToEmailRecipients < ActiveRecord::Migration[5.2]
  def change
    add_column :email_recipients, :students, :string
  end
end
