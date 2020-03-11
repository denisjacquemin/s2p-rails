class SendMailJob < ApplicationJob
   queue_as :SendMailJob



  def perform(message_id)
    puts "[SendMailJob info] processing: #{message_id}"

    message = Message.find message_id
    # # puts "[SendMailJob message: #{message.inspect}"
    ret = true
    unless message.nil?
       message.status = message.status == 'published' ? 'republished' : 'published'
       message.scheduled_publish = nil
       ret =  message.save
    end
    return ret
  end

  rescue_from(Exception) do |exception|
    # puts "Exception in SendMailJob: #{exception.inspect}"
    AlertAdminMailer.send_alert("Exception in SendMailJob: #{exception.inspect}").deliver_later
  end

  
end
