class SendMessageJob < ApplicationJob
  include Email
  include Notification

  queue_as :SendMessageJob



  def perform(message_id)
    puts "[SendMessageJob info] processing: #{message_id}"

    message = Message.find message_id
    # # puts "[SendMessageJob message: #{message.inspect}"
    ret = true
    unless message.nil?
      #  message.status = message.status == 'published' ? 'republished' : 'published'
       ret = message.update_columns(status: 'published', scheduled_publish: nil, updated_at: DateTime.now)
        
       message.index! # update Algolia Index

       sendMessageByEmail(message, 'now') if message.send_by_email
       send_message_notifications(message) if message.send_to_app

       if message.send_by_sms and message.school.has_sms_provision?
        find_student_ids(message.groups, message.students, message.school.iscity, message.message_categories)

        phones = Student.joins(:phones).where(id: student_ids).pluck( :id, :"phones.number")
        phones.each_slice(40) {|a| SendSmsJob.perform_now(message, a)}
      end

    end
    return ret
  end

  rescue_from(Exception) do |exception|
    # puts "Exception in SendMessageJob: #{exception.inspect}"
    AlertAdminMailer.send_alert("Exception in SendMessageJob: #{exception.inspect}").deliver_now
  end

  private
    def find_student_ids(groups, students, iscity, message_categories)
        ids = []
        ids = students if students.present?
        ids = ids + Student.by_groups(groups).pluck(:id) if groups.present?

        # if iscity then filter on categories
        if iscity
            ids_filtered = ids.select do |id|
            student_categories = Student.where(id: id).joins(:message_categories).pluck("message_categories.id")
            (student_categories & message_categories).any?
            end
            return ids_filtered.uniq
        else
            return ids.uniq
        end
    end
  
end
