class HandleSendgridWebhookJob < ApplicationJob
    queue_as :default
  
    def perform(event)
      school_id = event['sid'] || 'no_school_id'
      message_id = event['mid'] || 'no_message_id'
      
      students_names = Student.by_school(school_id).by_emails(event['email']).pluck(:firstname, :lastname)
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
  
    private
  
  
    def set_email_recipient_statistics(students, message_id, email, status, dateandtime)
  
      # if EmailRecipients does't already exist for a given students, message_id, email and status, then create it
      unless EmailRecipient.exists?(students: students, message_id: message_id, email: email, status: status)
        EmailRecipient.create(students: students, message_id: message_id, email: email, status: status, dateandtime: dateandtime)
      end
    end
  end
  