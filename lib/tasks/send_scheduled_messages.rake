desc "Send Scheduled Messages"
task :send_scheduled_messages => :environment do
  Rails.logger = Logger.new(STDOUT)

  @message_ids_to_send = Message.select(:id).where("scheduled_publish between ? and ?", 10.minutes.ago, Time.current)  

  @message_ids_to_send.each do |message|
    SendMailJob.perform_later(message.id)
  end
end