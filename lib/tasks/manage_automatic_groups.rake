desc "Manage automatic groups"
task :manage_automatic_groups => :environment do
  ActiveRecord::Base.logger = Logger.new(STDOUT)
  since = 1.hour.ago - 10.minutes
  students = Student.where('updated_at >= ?', since)
  puts "found #{students.size} updated #{since}"

  # for each students,
  # - check if classroom and level group exist
  # - add group to student if not already donea

  new_groups = []
  already_existing_groups = []
  students.each do |student|
    group = Group.where(name: student.classroom, school_id: student.school_id, updatable: false)
    if group.empty?
      group_to_add = {name: student.classroom, school_id: student.school_id, updatable: false}
      if not new_groups.include? group_to_add
        new_groups << group_to_add
      end
    else
      already_existing_groups << group.first
    end
    group = Group.where(name: student.level, school_id: student.school_id, updatable: false)
    if group.empty?
      group_to_add = {name: student.level, school_id: student.school_id, updatable: false}
      if not new_groups.include? group_to_add
        new_groups << group_to_add
      end
    else
      already_existing_groups << group.first
    end
  end
  groups = []
  ActiveRecord::Base.transaction do
    groups = Group.create(new_groups)
  end
  groups = groups + already_existing_groups
  puts "groups: #{groups.inspect}"

  all_students_by_school = Group.where(school_id: students.pluck(:school_id).uniq, internal_id: 'all_students')

  ActiveRecord::Base.transaction do
    students.each do |student|

      g =  groups.select {|g| (g.name == student.classroom or g.name == student.level) and g.school_id == student.school_id}
      as = all_students_by_school.select {|as| as.school_id == student.school_id}

      student.groups = g.pluck(:id) + as.pluck(:id)
      student.save
    end
  end




  # add all_students group for each student

  # find groups not updatable with zero students and delete them
  empty_groups = Group.where(updatable: false).each do |group|
    group.destroy if group.students.size == 0
  end
  #empty_groups = Groups.updatable.where(students_size: 0)

end
