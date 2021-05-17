# invokation: rails delete_classroom_for_a_given_school[1]
desc "Delete Users for a given school"
task :delete_users_for_a_given_school => :environment do |task, args|
  school = School.find 345
  puts "number of messages: #{school.messages.count}"
  
  school.users.each do |user|
    random = ('a'..'z').to_a.shuffle[0,8].join
    user.update(email: @user.email + random, deleted_at: Time.current)
  end
end