desc "Send Scheduled Messages"
task :send_scheduled_messages => :environment do

  # AlertAdminMailer.send_alert("Send Scheduled Messages Running #{10.minutes.ago} <> #{Time.current}").deliver_later

  Rails.logger = Logger.new(STDOUT)


  @messages_to_send = Message.where("scheduled_publish between ? and ?", 10.minutes.ago, Time.current)  
  Rails.logger.debug "Number of messages found #{@messages_to_send.count}"


  # AlertAdminMailer.send_alert("message_to_send: #{@message_to_send.inspect}").deliver_later

  @messages_to_send.each do |message|
    # AlertAdminMailer.send_alert("Message to send: #{message.id}").deliver_later
    Rails.logger.debug "SendMessageob.perform_now(message.id) #{message.id}"

    if message.groups.present? or message.students.present?
      res = SendMessageJob.perform_now(message.id)
    end
    # message.status = message.status == 'published' ? 'republished' : 'published'
    # message.scheduled_publish = nil
    # ret =  message.save
  end
end