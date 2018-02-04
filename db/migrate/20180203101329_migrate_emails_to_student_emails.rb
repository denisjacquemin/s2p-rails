class MigrateEmailsToStudentEmails < ActiveRecord::Migration[5.0]
  def up
    Student.all.each do |student|
      unless student.emails_old.nil?
        emails = student.emails_old.split(' ')
        emails.each do |email|
          StudentEmail.create(email: email, student_id: student.id)
        end
      end
    end
    
  end
end
