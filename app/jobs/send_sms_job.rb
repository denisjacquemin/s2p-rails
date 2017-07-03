class SendSmsJob < ApplicationJob
  queue_as :default

  def perform(message, to=[], from="KonectoApp", type="text", delivery_receipt=true)
    NexmoSMS::sendMessages(message, to, from, type, delivery_receipt)
  end
end
