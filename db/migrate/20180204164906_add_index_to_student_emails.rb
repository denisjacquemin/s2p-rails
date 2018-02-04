class AddIndexToStudentEmails < ActiveRecord::Migration[5.0]
  def change
    add_index :student_emails, :email
    add_index :student_emails, :student_id
  end
end
