class SendMailJob < ApplicationJob
  queue_as :default

  def perform(message_id)
    puts "[SendMailJob info: #{message_id}]"
    message = Message.find message_id

    unless message.nil?
      message.status = message.status == 'published' ? 'republished' : 'published'
      message.scheduled_publish = nil
      message.save
    end
  end
end
