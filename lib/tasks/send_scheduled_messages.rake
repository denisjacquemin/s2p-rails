desc "Send Scheduled Messages"
task :send_scheduled_messages => :environment do
  console.log "[send_scheduled_messages] started"
  ActiveRecord::Base.logger = Logger.new(STDOUT)

  messages_to_send = Message.where("scheduled_publish between ? and ?", 10.minutes.ago, Time.current)

  console.log "[send_scheduled_messages] found #{messages_to_send.count} message(s)"


  messages_to_send.each do |message|
    console.log "Sending scheduled message: #{message.title}"
    message.status = 'published'
    message.scheduled_publish = nil
    message.save
  end
end