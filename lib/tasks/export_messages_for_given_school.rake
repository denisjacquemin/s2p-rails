# invokation: rails delete_classroom_for_a_given_school[1]
desc "Export messages for a given school"
task :export_messages_for_a_given_school => :environment do |task, args|
  school = School.find 345
  puts "number of messages: #{school.messages.count}"
  file = "#{Rails.root}/public/messages.csv"

  CSV.open( file, 'w' ) do |writer|
    table = school.messages.where(deleted: false)

    writer << ['title', 'content', 'created at', 'status', 'author', 'recipients']
    table.each do |m|
      writer << [m.title, m.content, m.created_at, m.status, m.author.fullname, m.recipients.map{ |r| r.student&.fullname}.join(', ') + m.groups.map {|g| Group.find(g).name }.join(', ')]
    end
  end
  
  
end