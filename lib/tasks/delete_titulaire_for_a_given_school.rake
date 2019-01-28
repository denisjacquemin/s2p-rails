# invokation: rails delete_classroom_for_a_given_school[1]
desc "Delete Classroom data for a given school"
task :delete_classroom_for_a_given_school, [:school_id] => :environment do |task, args|
  school_id = args.school_id
  puts "school_id: #{args.school_id}"
  school = School.find school_id
  puts "Delete Classroom for #{school.name}."

  students = school.students
  students.update_all(classroom: '')
  puts "Reindex! students to remove classrom form algolia's index"
  puts "and also destroy Groups"
end
