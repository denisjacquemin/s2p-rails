desc "Update Group Type"
task :update_group_type => :environment do |task|
  schools = School.where(id: 268)
  schools.each do |school|
    levels = school.students.pluck(:level).uniq
    classroom =  school.students.pluck(:classroom).uniq

    groups = Group.where(school_id: school.id, name: levels)
    groups.update_all(group_type: 'level')

  end
end