class CreateStudentFromCsvJob < ApplicationJob
  queue_as :default

  def perform(data, school_id, user)
    logger.info "perform CreateStudentFromCsvJob"

    # check authorization
    if user.schools.include?(school_id) and user.admin?

      groups = []

      data['school_id'] = school_id

      student = nil
      if (data[:code].nil?)
        student = Student.where(['firstname = ? and lastname = ? and school_id = ?', data[:firstname], data[:lastname], data['school_id']] ).first
      else
        student = Student.where(['code = ?', data[:code]]).first
      end

      if student.nil?
        @student = Student.new data
        logger.info "student to create #{@student.inspect}"

      # check access rights
        if @student.save
          logger.info "student #{@student.firstname} #{@student.lastname} successfully created"
        else
          logger.info "student create fail for #{@student.firstname} #{@student.lastname} #{@student.errors}"
        end
      else
        if student.update_attributes(data)
          logger.info "student #{student.firstname} #{student.lastname} updated"
        else
          logger.info "student update fail for #{student.firstname} #{student.lastname}"
        end
      end
    else
      logger.info "student update fail invalid authorization, for #{data.inspect},"
    end
  end
end
