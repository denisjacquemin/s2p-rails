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
          write_error_to_firebase(data, @student.errors, school_id, user.id)
          logger.info "student create fail for #{@student.firstname} #{@student.lastname} #{@student.errors}"
        end
      else
        if student.update_attributes(data)
          logger.info "student #{student.firstname} #{student.lastname} updated"
        else
          write_error_to_firebase(data, @student.errors, school_id, user.id)

          logger.info "student update fail for #{student.firstname} #{student.lastname}"
        end
      end
    else
      logger.info "student update fail invalid authorization, for #{data.inspect},"
    end
  end

  def write_error_to_firebase(data, errors, school_id, user_id)
    logger.debug "write_error_to_firebase"
    base_uri = Rails.application.secrets.firebase_base_uri
    secret_key = Rails.application.secrets.firebase_secret_key
    firebase = Firebase::Client.new(base_uri, secret_key)
    response = firebase.push("csv/#{school_id}/#{user_id}", { :data => data.select { |key, value| /firstname|lastname|emails|sent_message_by_email|level|classroom/.match(key.to_s) }.values().join(', '),
                                                              :errors => errors.full_messages.join(', '),
                                                              :created_at => I18n.l(Time.now).to_datetime().in_time_zone
                                                            })
    logger.debug "Firebase response: #{response.inspect}"
  end
end
