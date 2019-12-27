desc "Send Scheduled Messages"
task :send_scheduled_messages => :environment do
  puts "[send_scheduled_messages] started"
  ActiveRecord::Base.logger = Logger.new(STDOUT)

  found = Message.where("scheduled_publish between ? and ?", 10.minutes.ago.utc, DateTime.now.utc).count
  puts "found: #{found}"

end