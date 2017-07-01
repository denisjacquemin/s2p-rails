class CreateStudentFromCsvJob < ApplicationJob
  include Code
  queue_as :default

  def perform(rows, school_id, user)
    logger.info "perform CreateStudentsFromCsvJob"
    rows.each do |data|
      if data[:winpage_matricule].nil?
        handle_simple_csv_student(data, school_id, user.id)
      else
        handle_winpage_student(data, school_id, user.id)
      end
    end


    #
    #   student_data = {}
    #   student_data[:firstname] =  data[:firstname]
    #   student_data[:lastname] = data[:lastname]
    #   student_data[:level] = data[:level]
    #   student_data[:classroom] = data[:classroom]
    #   student_data[:emails] = [data[:emails], data[:emails2]].join(' ').strip
    #   student_data[:code] = data[:code]
    #   student_data[:winpage_matricule] = data[:winpage_matricule]
    #
    #
    #   if student_data[:code].nil?
    #     student_data['school_id'] = school_id
    #     unless Student.exists?(['firstname = ? and lastname = ? and school_id = ?', student_data[:firstname], student_data[:lastname], student_data['school_id']])
    #       student = Student.new student_data
    #       student
    #       student_key = shake_name(student.firstname,student.lastname).join
    #       hash = compute_code(school_id, student_key)
    #       student.code = 's' + hash[0] + hash[1].last(4 + student_key.length % 3)
    #       recordUniqueCount = 0
    #       begin
    #         unless student.save
    #           write_error_to_firebase(data, student.errors, school_id, user.id)
    #           #logger.info "student create fail for #{@student.firstname} #{@student.lastname} #{@student.errors}"
    #         end
    #       rescue ActiveRecord::RecordNotUnique => e
    #
    #         #logger.info "CreateStudentFromCsvJob::Error::RecordNotUnique #{e.inspect}"
    #         number_of_collision = number_of_collision + 1
    #         recordUniqueCount = recordUniqueCount + 1
    #         logger.debug "[collision]: #{student.code} for [#{student_key}] #{hash[1]}"
    #         #key = "#{rand(999999)}#{@student.school_id}#{@student.firstname}#{@student.lastname}"
    #         student.code = 's' + hash[0] + hash[1].last(4 + recordUniqueCount + student_key.length % 3)
    #         retry
    #       rescue Exception => e
    #         logger.info "CreateStudentFromCsvJob::Error #{e.inspect}"
    #         retry
    #       end
    #     else
    #       write_error_to_firebase(data, "La paire nom/prénom existe déjà, créez un homonyme via le bouton 'Nouvel élève'", school_id, user.id)
    #     end
    #   else
    #     # code or winpage_matricule given for the student
    #     # get student by code and current school
    #     student = Student.where('(code = ? or winpage_matricule = ?) and school_id = ?', student_data[:code], student_data[:winpage_matricule], school_id: school_id).first
    #     if student.nil?
    #       write_error_to_firebase(student_data, "Pas d'élève trouvé pour le code #{student_data[:code]}", school_id, user.id)
    #     elsif student.update_attributes(student_data)
    #       logger.info "student #{student.firstname} #{student.lastname} updated"
    #     else
    #       write_error_to_firebase(data, student.errors, school_id, user.id)
    #       logger.info "student update fail for #{student.firstname} #{student.lastname}"
    #     end
    #   end
    #
    # end
    # logger.info "Number Of collision: #{number_of_collision}"

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

  def handle_simple_csv_student(data, school_id, user_id)
    number_of_collision = 0
    student_data = data
    student_data['school_id'] = school_id
    if student_data[:code].nil?
      unless Student.exists?(['firstname = ? and lastname = ? and school_id = ?', student_data[:firstname], student_data[:lastname], student_data['school_id']])
        student = Student.new student_data
        student
        student_key = shake_name(student.firstname,student.lastname).join
        hash = compute_code(school_id, student_key)
        student.code = 's' + hash[0] + hash[1].last(4 + student_key.length % 3)
        recordUniqueCount = 0
        begin
          unless student.save
            write_error_to_firebase(data, student.errors, school_id, user_id)
            #logger.info "student create fail for #{@student.firstname} #{@student.lastname} #{@student.errors}"
          end
        rescue ActiveRecord::RecordNotUnique => e

          #logger.info "CreateStudentFromCsvJob::Error::RecordNotUnique #{e.inspect}"
          number_of_collision = number_of_collision + 1
          recordUniqueCount = recordUniqueCount + 1
          logger.debug "[collision]: #{student.code} for [#{student_key}] #{hash[1]}"
          #key = "#{rand(999999)}#{@student.school_id}#{@student.firstname}#{@student.lastname}"
          student.code = 's' + hash[0] + hash[1].last(4 + recordUniqueCount + student_key.length % 3)
          retry
        rescue Exception => e
          logger.info "CreateStudentFromCsvJob::Error #{e.inspect}"
          retry
        end
      else
        write_error_to_firebase(data, "La paire nom/prénom existe déjà, créez un homonyme via le bouton 'Nouvel élève'", school_id, user.id)
      end
    else
      # get student by code and current school
      student = Student.where('code = ? and school_id = ?', student_data[:code], school_id: school_id).first
      if student.nil?
        write_error_to_firebase(student_data, "Pas d'élève trouvé pour le code #{student_data[:code]}", school_id, user_id)
      elsif student.update_attributes(student_data)
        logger.info "student #{student.firstname} #{student.lastname} updated"
      else
        write_error_to_firebase(data, student.errors, school_id, user_id)
        logger.info "student update fail for #{student.firstname} #{student.lastname}"
      end
    end
  end

  def handle_winpage_student(data, school_id, user_id)
    number_of_collision = 0

    student_data = {}
    student_data[:school_id] = school_id
    student_data[:firstname] =  data[:firstname]
    student_data[:lastname] = data[:lastname]
    student_data[:level] = data[:level]
    student_data[:classroom] = data[:classroom]
    student_data[:emails] = [data[:emails], data[:emails2]].uniq.join(' ').strip
    student_data[:winpage_matricule] = data[:winpage_matricule].to_s

    # get already existing student for update
    student = Student.where('winpage_matricule = ? and school_id = ?', student_data[:winpage_matricule].to_s, student_data[:school_id]).first
    if student.nil?
      # student not found based on winpage_matricule, try to find it by firstname and lastname
      student = Student.where('firstname = ? and lastname = ? and school_id = ?', student_data[:firstname], student_data[:lastname], student_data[:school_id])
      if student.size == 1
        update_student(student.first, student_data, user_id)
      elsif student.size > 1
        write_error_to_firebase(student_data, "Les homonymes doivent être traité manuellement.", school_id, user_id)
      end
    else
      update_student(student, student_data, user_id)
    end

    if student.blank?
      # student don't exists yet, create a brand new one
      new_student = Student.new student_data
      student_key = shake_name(new_student.firstname,new_student.lastname).join
      hash = compute_code(school_id, student_key)
      new_student.code = 's' + hash[0] + hash[1].last(4 + student_key.length % 3)
      recordUniqueCount = 0
      begin
        unless new_student.save
          write_error_to_firebase(data, new_student.errors, school_id, user_id)
        end
      rescue ActiveRecord::RecordNotUnique => e
        number_of_collision = number_of_collision + 1
        recordUniqueCount = recordUniqueCount + 1
        logger.debug "[collision]: #{new_student.code} for [#{student_key}] #{hash[1]}"
        #key = "#{rand(999999)}#{@student.school_id}#{@student.firstname}#{@student.lastname}"
        new_student.code = 's' + hash[0] + hash[1].last(4 + recordUniqueCount + student_key.length % 3)
        retry
      rescue Exception => e
        logger.info "CreateStudentFromCsvWinpageJob::Error #{e.inspect}"
        retry
      end
    end
  end

  def update_student(student, attributes, user_id)
    begin
      if student.update_attributes(attributes)
        logger.info "student #{student.firstname} #{student.lastname} updated"
      else
        write_error_to_firebase(data, student.errors, student.school_id, user_id)
        logger.info "student update fail for #{student.firstname} #{student.lastname}"
      end
    rescue e
      logger.info e.inspect
    end
  end
end
