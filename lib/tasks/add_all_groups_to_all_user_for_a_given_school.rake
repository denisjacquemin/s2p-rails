namespace :user do
    # 4 saisons 82
    # demo 10
    desc "Add all groups to all users for a given school"
    task :add_all_groups_to_all_user_for_a_given_school => :environment do
        ActiveRecord::Base.logger = Logger.new(STDOUT)
        school_id = 82
        groups = Group.by_school(school_id)
        students = School.find(school_id).students

        users = User.by_school(school_id)
        users.each do |user|
            if user.user?
                user.groups = groups
                user.students = students
                user.save
            end
        end
    end
end