desc "Fix missing groups"
task :fix_missing_groups => :environment do |task, args|
  Rails.logger = Logger.new(STDOUT)

  res = []
  # School.all.each do |school|
    school = School.find 180
    groups = school.students.pluck(:classroom, :level).flatten.compact.uniq.reject(&:blank?)
    # check if group exist if not create it
    # groups.each do |group_name|
    #   unless Group.where('lower(name) = ? and school_id = ?', group_name.downcase.strip, school.id).first
    #     res.push "#{school.name} #{group_name}"
    #   end
    # end
  


    # create missing groups
    groups.each do |group_name|
      group = Group.find_or_create_group(group_name, school.id)
    end

    # update students with correct groups
    students = school.students
    students.each do |student|
      classroom = student.classroom
      level = student.level
      unless classroom.blank?
        classroom_group = Group.where('lower(name) = ? and school_id = ?', classroom.downcase.strip, school.id).first
        student.groups.delete(classroom_group.id)
        student.groups.push(classroom_group.id)
      end
      unless level.blank?
        level_group = Group.where('lower(name) = ? and school_id = ?', level.downcase.strip, school.id).first
        student.groups.delete(level_group.id)
        student.groups.push(level_group.id)
      end
      student.save
    end
  # end
end