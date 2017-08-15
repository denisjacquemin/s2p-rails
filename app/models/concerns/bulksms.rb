module Bulksms extend ActiveSupport::Concern
  #https://www.synbioz.com/blog/Rails_4_utilisation_des_concerns

  # def send_bulk_sms(message, numbers)
  #   logger.info "Sending #{message} to #{numbers.size} sms"
  #   sendMessageSMS(message, numbers)
  # end
  #
  #
  # def sendMessageSMS(message, numbers)
  #   @message = message
  #   nbr_sms_sent = 0
  #   if ENV["SMS_PROVIDER"] === 'CALLR'
  #     numbers.each do |number|
  #       if sendMessageCallr(@message[0...160], number)
  #         nbr_sms_sent = nbr_sms_sent + 1
  #       end
  #     end
  #   elsif ENV["SMS_PROVIDER"] === 'NEXMO'
  #     numbers.each do |number|
  #       sendMessageNexmo(@message[0...160], number)
  #     end
  #   end
  #   return nbr_sms_sent
  # end
  #
  # def sendMessageNexmo(message, number)#, from="KonectoApp", type="text", delivery_receipt=true)
  #     puts "([SMS] NEXMO sendMessages [#{ENV["NEXMO_KEY"]}]) Sending SMS to (#{number}), message is #{message}"
  #     client = Nexmo::Client.new(key: ENV["NEXMO_KEY"], secret: ENV["NEXMO_SECRET"])
  #
  #     puts "[SMS] NEXMO sending to #{number} with client: #{client.inspect()}"
  #     response = client.send_message(from: "KonectoApp", to: number, text: message)
  #     puts "[SMS] NEXMO response: #{response.inspect()}"
  #     if response['messages'][0]['status'] == '0'
  #       puts "[SMS] NEXMO Sent message #{response['messages'][0]['message-id']}"
  #     else
  #       puts "[SMS] NEXMO Error SMS: #{response['messages'][0]['error-text']}"
  #     end
  # end
  #
  # def sendMessageCallr(message, number)
  #   begin
  #     optionSMS = { :nature => 'ALERTING', :force_encoding => 'GSM' }
  #     puts "[SMS] CALLR sending #{message} to #{number}"
  #     api = CALLR::Api.new(ENV["CALLR_LOGIN"], ENV["CALLR_PASSWORD"])
  #     return api.call('sms.send', 'SMS', number, message, optionSMS)
  #   rescue CALLR::CallrException, CALLR::CallrLocalException => e
  #     puts "[SMS] CALLR ERROR SMS (#{number}): #{e.code}"
  #     puts "[SMS] CALLR ERROR SMS (#{number}) MESSAGE: #{e.msg}"
  #     puts "[SMS] CALLR ERROR SMS (#{number})DATA: ", e.data
  #   end
  # end
end
