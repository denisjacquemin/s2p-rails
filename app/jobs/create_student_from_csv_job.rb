class CreateStudentFromCsvJob < ApplicationJob
  include Code
  queue_as :default

  rescue_from(Exception) do |exception|
   logger "Exception in CreateStudentFromCsvJob: #{exception.inspect}"
  end

  def error(job, exception)
    AlertAdminMailer.send_alert(job.inspect + exception.inspect).deliver_later
  end

  def failure(job)
    AlertAdminMailer.send_alert(job.inspect).deliver_later
  end

  def perform(rows, school_id, user)

    logger.info "perform CreateStudentsFromCsvJob"
    i = 0
    puts "rows #{rows.size}"
    rows.each do |data|
      puts "row #{i}: #{data[:winpage_matricule]}"
      if data[:winpage_matricule].present? # Winpage ou Creos
        handle_winpage_student(data, school_id, user.id)
      elsif data[:proeco_id].present?
        handle_proeco_student(data, school_id, user.id)
      else
        handle_simple_csv_student(data, school_id, user.id)
      end
      i = i+1
    end
    AlertAdminMailer.send_alert("CreateStudentFromCsvJob starting for school #{school_id} : #{i}/#{rows.size} rows processed / #{data.inspect}").deliver_later


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
    emails = data.delete(:emails)
    student_data = data
    student_data[:student_emails] = []
    student_data[:student_emails] = buildEmailArray(emails) unless emails.nil?
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
        write_error_to_firebase(data, "La paire nom/prénom existe déjà, créez un homonyme via le bouton 'Nouvel élève'", school_id, user_id)
      end
    else
      # get student by code and current school
      student = Student.where('code = ? and school_id = ?', student_data[:code], school_id).first
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

  def handle_proeco_student(data, school_id, user_id)
    student_data = {}
    student_data[:proeco_id] = data[:proeco_id].to_s
    student_data[:school_id] = school_id
    student_data[:firstname] = data[:firstname]
    student_data[:lastname] = data[:lastname]
    student_data[:level] = "#{data[:level1]}#{data[:level2]}"
    emails = [data[:email1], data[:email2], data[:email3], data[:email4]].uniq.join(' ').strip
    student_data[:student_emails] = buildEmailArray(emails)
    student_data[:phones] = buildPhoneArray(data)


    # get already existing student for update
    student = Student.where('proeco_id = ? and school_id = ?', student_data[:proeco_id].to_s, student_data[:school_id]).first

    if student.nil?
      # student not found based on proeco_id, try to find it by firstname and lastname
      student = Student.where('firstname = ? and lastname = ? and school_id = ?', student_data[:firstname], student_data[:lastname], student_data[:school_id])
      if student.size == 1
        update_student(student.first, student_data, user_id, emails)
      elsif student.size > 1
        write_error_to_firebase(student_data, "Les homonymes doivent être traité manuellement.", school_id, user_id)
      end
    else
      update_student(student, student_data, user_id, emails)
    end

    if student.blank?
      # student don't exists yet, create a brand new one
      create_new_student(student_data, school_id)
    end

  end

  def handle_winpage_student(data, school_id, user_id)
    number_of_collision = 0
    student_data = {}
    student_data[:school_id] = school_id
    student_data[:firstname] =  data[:firstname]
    student_data[:lastname] = data[:lastname]
    student_data[:level] = data[:level] if data[:level] # WinPage
    student_data[:level] = data[:level2] if data[:level2] # Creos
    student_data[:classroom] = [data[:firstname_classroom], data[:classroom]].join(' ').strip
    emails = [data[:emails], data[:emails2]].uniq.join(' ').strip
    student_data[:winpage_matricule] = data[:winpage_matricule].to_s

    # handle Creos info_contact, build an array of emails and an array of phones
    emailsArray = []
    phonesArray = []
    contactArray = [data[:info_contact1], data[:info_contact2], data[:info_contact3], data[:info_contact4], data[:info_contact5], data[:info_contact6], data[:info_contact7], data[:info_contact8], data[:info_contact9]].compact.uniq
    contactArray.each { |contact|
      if contact.to_s.include?('@')
        emailsArray.push(contact)
      else
        phonesArray.push(contact)
      end
    } if contactArray.any?
    emails = emailsArray.uniq.join(' ').strip if emailsArray.any?

    student_data[:phones] = buildArrayOfPhone(phonesArray) if phonesArray.any?
    student_data[:phones] = buildPhoneArray(data) unless phonesArray.any?

    student_data[:student_emails] = buildEmailArray(emails)
    # get already existing student for update
    student = Student.where('winpage_matricule = ? and school_id = ?', student_data[:winpage_matricule].to_s, student_data[:school_id]).first
    if student.nil?
      # student not found based on winpage_matricule, try to find it by firstname and lastname
      student = Student.where('firstname = ? and lastname = ? and school_id = ?', student_data[:firstname], student_data[:lastname], student_data[:school_id])
      if student.size == 1
        update_student(student.first, student_data, user_id, emails)
      elsif student.size > 1
        write_error_to_firebase(student_data, "Les homonymes doivent être traité manuellement.", school_id, user_id)
      end
    else
      update_student(student, student_data, user_id, emails)
    end

    if student.blank?
      create_new_student(student_data, school_id)
      # student don't exists yet, create a brand new one
    end
  end

  def create_new_student(data, school_id)
    number_of_collision = 0
    new_student = Student.new data
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

  def update_student(student, attributes, user_id, emails)
    begin
      attributes[:student_emails] = merge_new_and_old_emails(student.student_emails, attributes[:student_emails])
      attributes[:phones] = merge_new_and_old_phones(student.phones, attributes[:phones])
      if student.update_attributes(attributes)
        logger.info "student #{student.firstname} #{student.lastname} updated"
      else
        write_error_to_firebase(data, student.errors, student.school_id, user_id)
        logger.info "student update fail for #{student.firstname} #{student.lastname}"
      end
    rescue Exception => e
      logger.info e.inspect
    end
  end

  def merge_new_and_old_emails(old_emails, new_emails)

    return nil if old_emails.nil? and new_emails.nil?
    return old_emails if new_emails.nil?
    return new_emails if old_emails.nil?

    # keep old_mail if present in new_emails
    newEmailsArray = new_emails.pluck(:email)
    # mergedEmails = old_emails.select { |old_email|
    #   newEmailsArray.include?(old_email.email)
    # }
    # add new_email only present in new_emails
    oldEmailsArray = old_emails.pluck(:email)
    # mergedEmails << new_emails.select { |new_email|
    #   not oldEmailsArray.include?(new_email.email)
    # }
    mergedEmails = old_emails + new_emails

    return mergedEmails.flatten.compact.uniq{|p| p.email }
  end

  def buildArrayOfPhone(numbers)
    numbers.map do |number|
      Phone.new number: number
    end
  end

  def buildArrayOfStudentEmail(emails)
    emails.map do |email|
      StudentEmail.new email: email
    end
  end

  def merge_new_and_old_phones(old_phones, new_phones)
    return nil if old_phones.nil? and new_phones.nil?
    return old_phones if new_phones.nil?
    return new_phones if old_phones.nil?

    mergedPhones = old_phones + new_phones
    return mergedPhones.flatten.compact.uniq{|p| p.number }
  end

  def buildPhoneArray(data)
    phonie1 = Phonie::Phone.parse(data[:phone1], country_code: '32') unless data[:phone1].nil?
    phone1 = phonie1.to_s unless phonie1.nil?
    phonie2 = Phonie::Phone.parse(data[:phone2], country_code: '32') unless data[:phone2].nil?
    phone2 = phonie2.to_s unless phonie2.nil?
    phonie3 = Phonie::Phone.parse(data[:phone3], country_code: '32') unless data[:phone3].nil?
    phone3 = phonie3.to_s unless phonie3.nil?
    phonie4 = Phonie::Phone.parse(data[:phone4], country_code: '32') unless data[:phone4].nil?
    phone4 = phonie4.to_s unless phonie4.nil?

    numbers = [phone1, phone2, phone3, phone4].flatten.uniq.compact
    return buildArrayOfPhone(numbers)

  end

  def buildEmailArray(emails)
    return buildArrayOfStudentEmail(emails.split(' '))
  end
end
