# invokation: rails delete_classroom_for_a_given_school[1]
desc "Fix all_students group"
task :fix_all_students_group => :environment do |task, args|
  Rails.logger = Logger.new(STDOUT)


  res = []
  School.all.each do |school|
    all_students_group = Group.where(internal_id: 'all_students', school_id: school.id).first
    all_students_group.students.count
    if school.students.count != all_students_group.students.count
    #   school.students.each do |student|
    #     student.groups.delete all_students_group.id
    #     student.groups.push all_students_group.id
    #     student.save
    #   end
      res.push "#{school.students.count} - #{all_students_group.students.count} #{school.name}"
    end
  end
  Rails.logger.info res
end
