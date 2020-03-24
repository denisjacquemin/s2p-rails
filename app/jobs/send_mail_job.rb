class SendMailJob < ApplicationJob
  include Email
  include Notification

  queue_as :SendMailJob



  def perform(message_id)
    puts "[SendMailJob info] processing: #{message_id}"

    message = Message.find message_id
    # # puts "[SendMailJob message: #{message.inspect}"
    ret = true
    unless message.nil?
      #  message.status = message.status == 'published' ? 'republished' : 'published'
       ret = message.update_columns(status: 'published', scheduled_publish: nil, updated_at: DateTime.now)

       sendMessageByEmail(message, 'now') if message.send_by_email
       send_message_notifications(message) if message.send_to_app

    end
    return ret
  end

  rescue_from(Exception) do |exception|
    # puts "Exception in SendMailJob: #{exception.inspect}"
    AlertAdminMailer.send_alert("Exception in SendMailJob: #{exception.inspect}").deliver_now
  end

  
end
