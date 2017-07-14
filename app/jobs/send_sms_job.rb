class SendSmsJob < ApplicationJob
  queue_as :default

  def perform(message, phones)
    logger.info "[SMS] In SendSmsJob #{message.title} #{phones.inspect}"
    sendMessageSMS(message, phones)
  end

  rescue_from(Exception) do |exception|
   logger "Exception in SendSmsJob: #{exception.inspect}"
  end

private
  def sendMessageSMS(message, phones)
    nbr_sms_sent = 0
    # if ENV["SMS_PROVIDER"] === 'CALLR'
    nbr_sms_sent = sendMessageCallr(message, phones)
    # elsif ENV["SMS_PROVIDER"] === 'NEXMO'
    #   numbers.each do |number|
    #     sendMessageNexmo(@message[0...160], number)
    #   end
    # end
    return nbr_sms_sent
  end

  def sendMessageNexmo(message, number)#, from="KonectoApp", type="text", delivery_receipt=true)
      puts "([SMS] NEXMO sendMessages [#{ENV["NEXMO_KEY"]}]) Sending SMS to (#{number}), message is #{message}"
      client = Nexmo::Client.new(key: ENV["NEXMO_KEY"], secret: ENV["NEXMO_SECRET"])

      puts "[SMS] NEXMO sending to #{number} with client: #{client.inspect()}"
      response = client.send_message(from: "KonectoApp", to: number, text: message)
      puts "[SMS] NEXMO response: #{response.inspect()}"
      if response['messages'][0]['status'] == '0'
        puts "[SMS] NEXMO Sent message #{response['messages'][0]['message-id']}"
      else
        puts "[SMS] NEXMO Error SMS: #{response['messages'][0]['error-text']}"
      end
  end

  def sendMessageCallr(message, phones)
    begin
      puts "[SMS] CALLR sending #{message.title} to #{phones}"
      api = CALLR::Api.new(ENV["CALLR_LOGIN"], ENV["CALLR_PASSWORD"])
      nbr_sms_sent = 0
      phones.each do |phone|
        optionSMS = { :nature => 'ALERTING', :force_encoding => 'GSM', :user_data => "mid#{message.id};sid#{message.school_id};pid#{phone.id}" }
        puts "[SMS] CALLR optionSMS: #{optionSMS.inspect}"
        begin
          if api.call('sms.send', 'SMS', phone.number, message.title, optionSMS)
            nbr_sms_sent = nbr_sms_sent + 1
          end
        rescue CALLR::CallrException, CALLR::CallrLocalException => e
          puts "[SMS] CALLR ERROR SMS: #{e.inspect()} #{e.code} #{e.to_s}"
          puts "[SMS] CALLR ERROR SMS MESSAGE: #{e.msg}"
          puts "[SMS] CALLR ERROR SMS DATA: ", e.data
        end
      end
      return nbr_sms_sent
    rescue CALLR::CallrException, CALLR::CallrLocalException => e
      puts "[SMS] CALLR ERROR SMS: #{e.inspect()}"
      puts "[SMS] CALLR ERROR SMS MESSAGE: #{e.msg}"
      puts "[SMS] CALLR ERROR SMS DATA: ", e.data
    end
  end
end
