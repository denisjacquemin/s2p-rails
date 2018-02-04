class AddIndexToStudentEmails < ActiveRecord::Migration[5.0]
  def change
    add_index :student_emails, :student_
  end
end
