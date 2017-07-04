class SendSmsJob < ApplicationJob
  queue_as :default

  def perform(message, to=[], from="KonectoApp", type="text", delivery_receipt=true)
    logger.info "[SMS] In SendSmsJob #{message} #{to.inspect}"
    sendMessagesNexmo(message, to, from, type, delivery_receipt)
  end

private
  def sendMessagesNexmo(message, to=[], from="KonectoApp", type="text", delivery_receipt=true)
      logger.info "([SMS] sendMessages [#{ENV["NEXMO_KEY"]}]) Sending SMS to (#{to.inspect}), message is #{message}"
      client = Nexmo::Client.new(key: ENV["NEXMO_KEY"], secret: ENV["NEXMO_SECRET"])

      @message = '[KonectoApp] ' + message

      logger.info "to: #{to.compact.uniq.inspect}"
      to.compact.uniq.each do |number|
        logger.info "[SMS] sending to #{number} with client: #{client.inspect}"
        response = client.send_message(from: from, to: number, text: @message[0...160])
        logger.info "[SMS] response: #{response.inspect}"
        if response['messages'][0]['status'] == '0'
          logger.info "[SMS] Sent message #{response['messages'][0]['message-id']}"
        else
          logger.info "[SMS] Error: #{response['messages'][0]['error-text']}"
        end
      end
  end
end
