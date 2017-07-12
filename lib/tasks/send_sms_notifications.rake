desc "Send SMS Notifications"
task :send_sms_notifications => :environment do
  ActiveRecord::Base.logger = Logger.new(STDOUT)

  puts "[SMS] running: send_sms_notifications task"

  nbr_sms_sent = 0

  # find message with status waiting_for_approval and not older than 1 day and wfa_sms_sent to false
  wfa_messages = Message.where('status = ? and updated_at > ? and wfa_sms_sent = ?', 2, 1.day.ago, false)
  wfa_messages.each do |message|
    sms_message = "#{message.author.firstname} demande une approbation: #{message.title}"
    phone_numbers = message.school.admins.map{|u| u.phone}
    wfa_nbr_sms_sent = sendMessageSMS(sms_message, phone_numbers)
    message.update_column('wfa_sms_sent', true) # skip updated_at automatic update
    nbr_sms_sent = nbr_sms_sent + wfa_nbr_sms_sent
  end

  # find message with status approval_accepted and not older than 1 day and aa_sms_sent to false
  aa_messages = Message.where('status = ? and updated_at > ? and aa_sms_sent= ?', 4, 1.day.ago, false)
  aa_messages.each do |message|
    sms_message = "Message approuvé: #{message.title}"
    phone_numbers = [message.author.phone]
    aa_nbr_sms_sent = sendMessageSMS(sms_message, phone_numbers)
    message.update_column('aa_sms_sent', true) # skip updated_at automatic update
    nbr_sms_sent = nbr_sms_sent + aa_nbr_sms_sent
  end

  # find message with status approval_refused and not older than 1 day and ar_sms_sent to false
  ar_messages = Message.where('status = ? and updated_at > ? and ar_sms_sent = ?', 3, 1.day.ago, false)
  ar_messages.each do |message|
    sms_message = "Message refusé: #{message.title}"
    phone_numbers = [message.author.phone]
    ar_nbr_sms_sent = sendMessageSMS(sms_message, phone_numbers)
    message.update_column('ar_sms_sent', true) # skip updated_at automatic update
    nbr_sms_sent = nbr_sms_sent + ar_nbr_sms_sent
  end
  puts "[SMS] Number sms sent: #{nbr_sms_sent}"
end

def sendMessageSMS(message, numbers)
  @message = '[Konecto] ' + message
  nbr_sms_sent = 0
  if ENV["SMS_PROVIDER"] === 'CALLR'
    numbers.each do |number|
      if sendMessageCallr(@message[0...70], number)
        nbr_sms_sent = nbr_sms_sent + 1
      end
    end
  elsif ENV["SMS_PROVIDER"] === 'NEXMO'
    numbers.each do |number|
      sendMessageNexmo(@message[0...70], number)
    end
  end
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

def sendMessageCallr(message, number)
  begin
    optionSMS = { :nature => 'ALERTING' }
    puts "[SMS] CALLR sending #{message} to #{number}"
    api = CALLR::Api.new(ENV["CALLR_LOGIN"], ENV["CALLR_PASSWORD"])
    return api.call('sms.send', 'SMS', number, message, optionSMS)
  rescue CALLR::CallrException, CALLR::CallrLocalException => e
    puts "[SMS] CALLR ERROR SMS: #{e.code}"
    puts "[SMS] CALLR ERROR SMS MESSAGE: #{e.msg}"
    puts "[SMS] CALLR ERROR SMS DATA: ", e.data
  end
end

# def sendMessagePlivo(message, number)
#
#   api = RestAPI.new(AUTH_ID, AUTH_TOKEN)
#   params = {
#     #'src' => '1111111111', # Sender's phone number with country code
#     'dst' => number, # Receiver's phone Number with country code
#     'text' => message
#     #'url' => 'http://example.com/report/', # The URL to which with the status of the message is sent
#     'method' => 'POST' # The method used to call the url
#
#     response = api.send_message(params)
#     puts "[SMS] PLIVO response: #{response.inspect}"
# end
