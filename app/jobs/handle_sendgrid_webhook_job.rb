class HandleSendgridWebhookJob < ApplicationJob
  queue_as :default
  def perform(json)
    if json.is_a?(Array)
      puts ("json is an array")
      json.each do |json_to_process|
        if json_to_process.is_a?(Array)
          json_to_process.each do |jtprocess|
            event = jtprocess.as_json
            perform_one_event(event)
          end
        else
          event = json_to_process.as_json
          perform_one_event(event)
        end
      end
    else
      puts ("json is not an array")
      perform_one_event(json.as_json)
    end
  end

  private


  def perform_one_event(event)

    school_id = event['sid'] || 'no_school_id'
    message_id = event['mid'] || 'no_message_id'
    
    students_names = Student.by_school(school_id).by_emails(event['email']).pluck(:firstname, :lastname)
    puts "students_names: #{students_names}"
    source = event['email']
    if students_names.any?
      names = students_names.map do |a_student|
        a_student.join(' ')
      end.join(', ')
      source = "#{event['email']} (#{names})"
    end


    student_id = Student.by_school(school_id).by_emails(event['email']).pluck(:id)
    # sendgrid events: One of: bounce, deferred, delivered, dropped, processed, click, open, spamreport, unsubscribe
    if event['event'] == 'open'
      puts "Event is open"
      # student_recipients = StudentRecipient.where(student_id: student_id, message_id: message_id)
      # unless student_recipients.nil?
      #   student_recipients.update_all(viewed_by_email: true)
      # end
      set_email_recipient_statistics(source, message_id, event['email'], event['event'], I18n.l(Time.at(event['timestamp']).to_datetime().in_time_zone, format: :short))
    end
    if ["delivered", "bounce", "dropped"].include?(event['event'])
      set_email_recipient_statistics(source, message_id, event['email'], event['event'], I18n.l(Time.at(event['timestamp']).to_datetime().in_time_zone, format: :short))
    end
  end

  def set_email_recipient_statistics(students, message_id, email, status, dateandtime)
    puts "In set_email_recipient_statistics: students: #{students}; message_id: #{message_id}; email: #{email}; status: #{status}; dateandtime: #{dateandtime}"
    # if EmailRecipients does't already exist for a given students, message_id, email and status, then create it
    unless EmailRecipient.exists?(students: students, message_id: message_id, email: email, status: status)
      EmailRecipient.create(students: students, message_id: message_id, email: email, status: status, dateandtime: dateandtime)
    end
  end
end
