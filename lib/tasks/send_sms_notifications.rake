desc "Send SMS Notifications"
task :send_sms_notifications => :environment do
  ActiveRecord::Base.logger = Logger.new(STDOUT)

  puts "[SMS] running: send_sms_notifications task"

  # find message with status waiting_for_approval and not older than 1 day and wfa_sms_sent to false
  wfa_messages = Message.where('status = ? and updated_at > ? and wfa_sms_sent = ?', 2, 1.day.ago, false)
  wfa_messages.each do |message|
    sms_message = "#{message.author.firstname} demande une approbation: #{message.title}"
    phone_numbers = message.school.admins.map{|u| u.phone}
    phone_numbers.each do |number|
      sendMessagesNexmo(sms_message, number)
    end
    message.update_column('wfa_sms_sent', true) # skip updated_at automatic update
  end

  # find message with status approval_accepted and not older than 1 day and aa_sms_sent to false
  aa_messages = Message.where('status = ? and updated_at > ? and aa_sms_sent= ?', 4, 1.day.ago, false)
  aa_messages.each do |message|
    sms_message = "Message approuvé: #{message.title}"
    phone_numbers = [message.author.phone]
    phone_numbers.each do |number|
      sendMessagesNexmo(sms_message, number)
    end
    message.update_column('aa_sms_sent', true) # skip updated_at automatic update
  end

  # find message with status approval_refused and not older than 1 day and ar_sms_sent to false
  ar_messages = Message.where('status = ? and updated_at > ? and ar_sms_sent = ?', 3, 1.day.ago, false)
  ar_messages.each do |message|
    sms_message = "Message refusé: #{message.title}"
    phone_numbers = [message.author.phone]
    phone_numbers.each do |number|
      sendMessagesNexmo(sms_message, number)
    end
    message.update_column('ar_sms_sent', true) # skip updated_at automatic update
  end


end

def sendMessagesNexmo(message, number)#, from="KonectoApp", type="text", delivery_receipt=true)
    puts "([SMS] sendMessages [#{ENV["NEXMO_KEY"]}]) Sending SMS to (#{number}), message is #{message}"
    client = Nexmo::Client.new(key: ENV["NEXMO_KEY"], secret: ENV["NEXMO_SECRET"])

    @message = '[KonectoApp] ' + message

    puts "[SMS] sending to #{number} with client: #{client.inspect()}"
    response = client.send_message(from: "KonectoApp", to: number, text: @message[0...160])
    puts "[SMS] response: #{response.inspect()}"
    if response['messages'][0]['status'] == '0'
      puts "[SMS] Sent message #{response['messages'][0]['message-id']}"
    else
      puts "[SMS] Error: #{response['messages'][0]['error-text']}"
    end
end
