desc "Send Scheduled Messages"
task :send_scheduled_messages => :environment do
  Rails.logger = Logger.new(STDOUT)

  @message_to_send = Message.where("scheduled_publish between ? and ?", 10.minutes.ago, Time.current)  

  @message_to_send.each do |message|
    message.status = message.status == 'published' ? 'republished' : 'published'
    message.scheduled_publish = nil
    message.save  end
end