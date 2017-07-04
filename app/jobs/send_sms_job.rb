class SendSmsJob < ApplicationJob
  queue_as :default

  def perform(message, to=[], from="KonectoApp", type="text", delivery_receipt=true)
    logger.info "[SMS] In SendSmsJob #{message} #{to.inspect}"
    begin
      NexmoSMS::sendMessages(message, to, from, type, delivery_receipt)
    rescue Exception => e
      logger.info "[SMS] Error: #{e.inspect}"
    end
  end
end
