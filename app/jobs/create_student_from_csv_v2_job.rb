class CreateStudentFromCsvV2Job < ApplicationJob
    include Code
    queue_as :default
  
    rescue_from(Exception) do |exception|
      puts "[CreateStudentFromCsvV2Job info] in rescue_from: #{exception.inspect}"
      AlertAdminMailer.send_alert(exception.inspect).deliver_later
    end

    def failure(job)
        puts "[CreateStudentFromCsvV2Job info] in failure: #{job.inspect}"
        AlertAdminMailer.send_alert(job.inspect).deliver_later
    end

    def perform(rows, school_id, user)
        rows.each do |data|
            if data[:firstname].present? and data[:lastname].present? # check if mandatory fields are presents
                create_or_update_student(data, school_id, user.id)
            end
        end
    end

    def create_or_update_student(data, school_id, user_id)

        student_data = build_student_data(data, school_id)

        student = get_already_existing_student_for_update(student_data)
                
        if student.blank?
            create_new_student(student_data, school_id)
        else
            update_student(student, student_data, user_id)
        end
    end
    

    private

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

    def build_student_data(data, school_id)
        student_data = {}

        student_data[:school_id] = school_id

        # common
        student_data[:firstname] = data[:firstname]
        student_data[:lastname] = data[:lastname]
        student_data[:level] = "#{data[:level1]}#{data[:level2]}"
        student_data[:classroom] = data[:classroom] if data[:classroom].present?

        emailsArray =  data[:emails].present? ?data[:emails]&.split(' ') : []

        ### data from proeco with or without proecoid
        student_data[:proeco_id] = data[:proeco_id].to_s
        emailsArray = [data[:email1], data[:email2], data[:email3], data[:email4], data[:email_responsable]] if data[:email1].present? or data[:email2].present? or data[:email3].present? or data[:email4].present? or data[:email_responsable].present?
        phonesArray = [data[:phone1], data[:phone2]]

        ### data from WinPage or Creos
        if data[:winpage_matricule].present? # Winpage ou Creos

            student_data[:level] = data[:level] if data[:level] # WinPage
            student_data[:classroom] = [data[:firstname_classroom], data[:classroom]].join(' ').strip
            # emails = [data[:emails], data[:emails2], data[:emails1], data[:emails3]].uniq.join(' ').strip
            student_data[:winpage_matricule] = data[:winpage_matricule].to_s
            phonesArray = [data[:phone1], data[:phone2], data[:phone3], data[:info_contact1]]
            # handle Creos info_contact, build an array of emails and an array of phones
            
            contactArray = [data[:phone1], data[:phone2], data[:phone3], data[:phone4], data[:email2], data[:info_contact], data[:info_contact1], data[:info_contact2], data[:info_contact3], data[:info_contact4], data[:info_contact5], data[:info_contact6], data[:info_contact7], data[:info_contact8], data[:info_contact9]].compact.uniq
            if contactArray.any?
                emailsArray = []
                phonesArray = []
                contactArray.each { |contactElem|
                    contacts = contactElem.to_s.split(' ')
                    contacts.each { |contact|
                        if contact.to_s.include?('@')
                        emailsArray.push(contact)
                        else
                        phonesArray.push(contact)
                        end
                    }
                }
            end
        end

        ### data from siel
        if data[:siel_id].present?
            student_data[:siel_id] = data[:siel_id].to_s
            # student_data[:level] = "#{data[:siel_annee_etude]}#{data[:level2]}"
            student_data[:classroom] = [data[:siel_prenom_tit], data[:siel_nom_tit]].join(' ').strip
            emailsArray = [data[:siel_email_1], data[:siel_email_2]]
            phonesArray = [data[:phone1], data[:phone2]]
        end


        # common for Winpage Creos and ProEco
        student_data[:phones] = buildArrayOfPhone(phonesArray) if phonesArray.any?
        student_data[:student_emails] = buildArrayOfStudentEmail(emailsArray) if emailsArray.any?
        return student_data
        
    end

    def get_already_existing_student_for_update(student_data)
        
        student = nil

        if student_data[:proeco_id].present?
            student = Student.where('proeco_id = ? and school_id = ?', student_data[:proeco_id].to_s, student_data[:school_id]).first
        end

        if student_data[:winpage_matricule].present?
            student = Student.where('winpage_matricule = ? and school_id = ?', student_data[:winpage_matricule].to_s, student_data[:school_id]).first
        end


        # student not found based on proeco_id/winpage_matricule, try to find it by firstname and lastname
        if student.nil?
            students = Student.where('firstname = ? and lastname = ? and school_id = ?', student_data[:firstname], student_data[:lastname], student_data[:school_id])
            if students.size == 1
              student = students.first
            elsif students.size > 1
              write_error_to_firebase(student_data, "Les homonymes doivent être traité manuellement.", school_id, user_id)
            end
        end

        return student
    end

    def update_student(student, attributes, user_id)
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
        numbers.map{|n| n.to_s.gsub(/\D/, '')}.compact.uniq.map do |number|
            Phone.new number: number
        end
    end

    def buildArrayOfStudentEmail(emails)
        emails.compact.uniq.map do |email|
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

end