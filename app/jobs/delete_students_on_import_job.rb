class DeleteStudentsOnImportJob < ApplicationJob
  queue_as :delete_students_on_import
  
  # rescue_from(Exception) do |exception|
  #   puts "[DeleteStudentsOnImportJob info] in rescue_from: #{exception.inspect}"
  #   AlertAdminMailer.send_alert(exception.inspect).deliver_later
  # end

  # def failure(job)
  #     puts "[DeleteStudentsOnImportJob info] in failure: #{job.inspect}"
  #     AlertAdminMailer.send_alert(job.inspect).deliver_later
  # end

  def perform(students_NOT_to_delete, school_id)
    
    all_students_for_a_given_school = Student.by_school(school_id).pluck(:id, :firstname, :lastname)
    
    student_ids_to_delete = all_students_for_a_given_school.select do |student|
      not students_NOT_to_delete.include?("#{student[1]&.upcase}##{student[2]&.upcase}")
    end.map{|s| s[0]}

    Student.by_school(school_id).where(id: student_ids_to_delete).destroy_all
    # delete all students not present in uploaded csv
    # Student.by_school(school_id).where.not(id: student_ids_NOT_to_delete).each do |s|
    #   s.delete
    # end
  end
end
