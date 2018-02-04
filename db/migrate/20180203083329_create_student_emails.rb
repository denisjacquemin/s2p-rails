class CreateStudentEmails < ActiveRecord::Migration[5.0]
  def change
    create_table :student_emails do |t|
      t.integer :student_id
      t.string :email

      t.timestamps
    end
  end
end
