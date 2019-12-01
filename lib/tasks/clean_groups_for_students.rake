desc "Clean Groups For Students"
task :clean_groups_for_students => :environment do
  ActiveRecord::Base.logger = Logger.new(STDOUT)
  school = School.find 221 # Lessines
  school.students.each do |student|
    classroom_id = Group.where(name: student.classroom, school_id: student.school_id, updatable: false).pluck(:id).first
    level_id = Group.where(name: student.level, school_id: student.school_id, updatable: false).pluck(:id).first

    student.groups << classroom_id unless student.groups.include?(classroom_id)
    student.groups << level_id unless student.groups.include?(level_id)
    student.save
  end
end
