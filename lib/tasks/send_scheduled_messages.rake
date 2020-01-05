desc "Send Scheduled Messages"
task :send_scheduled_messages => :environment do
  AlertAdminMailer.send_alert("Send Scheduled Messages Running #{10.minutes.ago} <> #{Time.current}").deliver_later

  # Rails.logger = Logger.new(STDOUT)
  

  @message_to_send = Message.where("scheduled_publish between ? and ?", 10.minutes.ago, Time.current)  
  
  AlertAdminMailer.send_alert("message_to_send: #{message_to_send.inspect}").deliver_later


  @message_to_send.each do |message|
    AlertAdminMailer.send_alert("Message to send: #{message.id}").deliver_later
    # logger.info "    SendMailJob.perform_later(message.id) #{message.id}"
    SendMailJob.perform_later(message.id)
  end
end