class CreateStudentFromCsvJob < ApplicationJob
  include Code
  queue_as :default

  def perform(rows, school_id, user)

    logger.info "perform CreateStudentsFromCsvJob"
    rows.each do |data|
      row_id = rand(999999)
      if data[:code].nil?
        data['school_id'] = school_id
        @student = Student.new data
        key = "#{@student.school_id}#{@student.firstname}#{@student.lastname}"
        @student.code = compute_code('s', key)
        logger.info "collision: [#{row_id}] #{@student.code} for [#{key}] (first comuputed code)"
        begin
          unless @student.save
            write_error_to_firebase(data, @student.errors, school_id, user.id)
            logger.info "student create fail for #{@student.firstname} #{@student.lastname} #{@student.errors}"
          end
        rescue ActiveRecord::RecordNotUnique => e
          logger.info "CreateStudentFromCsvJob::Error::RecordNotUnique #{e.inspect}"
          logger.info "collision: [#{row_id}] #{@student.code} for [#{key}]"
          key = "#{rand(999999)}#{@student.school_id}#{@student.firstname}#{@student.lastname}"
          @student.code = compute_code('s',key )
          retry
        rescue Exception => e
          logger.info "CreateStudentFromCsvJob::Error #{e.inspect}"
          retry
        end
      else
        # code given for the student
        # get student by code and current school
        student = Student.where(code: data[:code], school_id: school_id).first
        if student.nil?
          write_error_to_firebase(data, "Pas d'élève trouvé pour le code #{data[:code]}", school_id, user.id)
        elsif student.update_attributes(data)
          logger.info "student #{student.firstname} #{student.lastname} updated"
        else
          write_error_to_firebase(data, @student.errors, school_id, user.id)
          logger.info "student update fail for #{student.firstname} #{student.lastname}"
        end
      end

    end
  end

private
  def write_error_to_firebase(data, errors, school_id, user_id)
    begin
      logger.debug "write_error_to_firebase"
      base_uri = Rails.application.secrets.firebase_base_uri
      secret_key = Rails.application.secrets.firebase_secret_key
      firebase = Firebase::Client.new(base_uri, secret_key)
      errorsMessage = errors if errors.is_a? String
      errorsMessage = errors.full_messages.join(', ') if errors.is_a? ActiveModel::Errors

      response = firebase.push("csv/#{school_id}/#{user_id}", { :data => data.select { |key, value| /firstname|lastname|emails|sent_message_by_email|level|classroom/.match(key.to_s) }.values().join(', '),
                                                                :errors => errorsMessage,
                                                                :created_at => I18n.l(Time.now.to_datetime().in_time_zone, format: :short)
                                                              })
      logger.debug "Firebase response: #{response.inspect}"
    rescue Exception => e
      logger.debug e
    end
  end
end
