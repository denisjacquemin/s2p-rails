desc "Set students code if blank"
task :set_students_code => :environment do
  puts "Set Students Code"
  students = Student.where(code: nil)
  students.each do |student|
    logger.debug "Set code for student #{student.fullname}"
    student.compute_code('s', "#{student.school_id}#{student.firstname}#{student.lastname}")
  end
end
