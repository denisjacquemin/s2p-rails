require 'nexmo'

module NexmoSMS
  def self.test
    "ok"
  end

  def self.sendMessages(message, to=[], from="KonectoApp", type="text", delivery_receipt=true)
    logger.debug "Sending SMS to (#{to.inspect}), message is #{message}"

    client = Nexmo::Client.new(key: Rails.application.secrets.nexmo_key, secret: Rails.application.secrets.nexmo_secret)

    @message = '[KonectoApp] ' + message

    to.compact.uniq.each do |number|
      response = client.send_message(from: from, to: number, text: @message[0...160])
      if response['messages'][0]['status'] == '0'
        logger.info "Sent message #{response['messages'][0]['message-id']}"
      else
        logger.info "Error: #{response['messages'][0]['error-text']}"
      end
    end
  end
end
