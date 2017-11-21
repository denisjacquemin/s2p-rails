# Group.where(id: @user_params[:group_ids]).collect {|g| g.students.pluck(:id)}.flatten.compact.uniq
#
desc "Update students for each User"
task :update_users_students => :environment do
  ActiveRecord::Base.logger = Logger.new(STDOUT)
  # Group.where(id: groups_ids).collect{|g| g.students.pluck(:id)}.flatten.compact.uniq

  User.all.each do |u|
    students_ids = Group.where(id: u.groups.pluck(:id)).collect{|g| g.students.pluck(:id)}.flatten.compact.uniq
    puts "students_ids: #{students_ids}"
  end
end
