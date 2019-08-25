task :remove_group => :environment do |task, args|
    Rails.logger = Logger.new(STDOUT)

    #remove wrong groups
    
    [419620, 419621, 419623, 419624, 419625].each do |group_id|
        
        students = Student.by_groups(group_id) 
        students.each do |s|
            s.groups.delete(group_id)
            s.save
        end
        Group.delete(group_id)
    end 


end  