desc "Clean MBC"
task :clean_mbc => :environment do
  ActiveRecord::Base.logger = Logger.new(STDOUT)
  school = School.find 470

  puts '#: ' + school.students.count.to_s

  students = school.students

  students_found = {}
  students.each do |student|
    students_found["#{student.firstname}_#{student.lastname}"] = students.where(firstname: student.firstname, lastname: student.lastname)
  end
  res = []
  # puts Hash[*students_found.first].inspect
  students_found.each do |key, value|

    if value.size > 1
      # res.push(key)

      to_keep = value[0]
      to_delete = value[1]
      if value[1].followers > 0
        to_keep = value[1]
        to_delete = value[0]
      end
      if to_keep.idifapme.nil?
        to_keep.idifapme = to_delete.idifapme
      end

      # keep groups from the latest
      if to_keep.created_at < to_delete.created_at
        to_keep.groups = to_delete.groups
      end

      to_keep.save
      to_delete.destroy
    end
  end
  # puts res.join(', ')
end