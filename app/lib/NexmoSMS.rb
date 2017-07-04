require 'nexmo'

module NexmoSMS
  def self.test
    "ok"
  end

  def self.sendMessages(message, to=[], from="KonectoApp", type="text", delivery_receipt=true)
    # begin
      Rails.logger.info "####### In NexmoSMS::sendMessages"
      Rails.logger.info "ENV['NEXMO_KEY']: #{ENV['NEXMO_KEY']}"
      Rails.logger.info "ENV['NEXMO_SECRET']: #{ENV['NEXMO_SECRET']}"
      Rails.logger.info "Rails.application.secrets.nexmo_key: #{Rails.application.secrets.nexmo_key}"
      Rails.logger.info "Rails.application.secrets.nexmo_secret: #{Rails.application.secrets.nexmo_secret}"


      Rails.logger.info "(sendMessages [#{ENV["NEXMO_KEY"]}]) Sending SMS to (#{to.inspect}), message is #{message}"
      # client = Nexmo::Client.new(key: ENV["NEXMO_KEY"], secret: ENV["NEXMO_SECRET"])
      #
      # @message = '[KonectoApp] ' + message
      #
      # to.compact.uniq.each do |number|
      #   response = client.send_message(from: from, to: number, text: @message[0...160])
      #   if response['messages'][0]['status'] == '0'
      #     Rails.logger.info "Sent message #{response['messages'][0]['message-id']}"
      #   else
      #     Rails.logger.info "Error: #{response['messages'][0]['error-text']}"
      #   end
      # end
    # rescue Exception => e
    #   Rails.logger.info "Error in NexmoSMS::sendMessages: #{e.inspect}"
    # end
  end
end
