class StudentsByMessagePublishJob < ApplicationJob
  queue_as :default

  def perform(student_ids, message_id, school_id)
    unless student_ids.nil?
      students = student_ids.map do |id|
        {student_id: id, message_id: message_id, school_id: school_id}
      end
      byebug
      StudentRecipient.create(students)
    end
  end
end
