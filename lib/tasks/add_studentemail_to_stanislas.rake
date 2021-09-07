desc "Clean Empty automatic groups"
task :add_studentemail_to_stanislas => :environment do
  ActiveRecord::Base.logger = Logger.new(STDOUT)
  school = School.find 616


  # File.open("emails.txt", "w" ) do |the_file|
    school.students.each do |student|
        new_email = "#{I18n.transliterate(student.firstname.downcase.gsub('-', '').gsub('\'', '').gsub(' ', ''))}.#{I18n.transliterate(student.lastname.downcase.gsub('-', '').gsub('\'', '').gsub(' ', ''))}@student.saintstanislas.be"
        student.student_emails << StudentEmail.create(email: new_email)
    end
  # end 
end