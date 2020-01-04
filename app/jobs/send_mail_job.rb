class SendMailJob < ApplicationJob
  queue_as :default

  def perform(message_id)
    puts "[SendMailJob info: #{message_id}]"
    message = Message.find message_id
    ret = true
    unless message.nil?
      message.status = message.status == 'published' ? 'republished' : 'published'
      message.scheduled_publish = nil
      ret =  message.save
    end
    return ret
  end

  rescue_from(Exception) do |exception|
    puts "Exception in SendMailJob: #{exception.inspect}"
   end
end
