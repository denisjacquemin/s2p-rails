class CreateStudentFromCsvAcawebJob < ApplicationJob
    include Code
    queue_as :create_student_from_csv_v3
  
    def perform(rows, school_id, user, upload_uniq_id)
      students = {}
      rows.each do |data|
        puts "[CreateStudentFromCsvV3Job info] processing: #{data[:firstname]} #{data[:lastname]}"
        firstname = data[:firstname]&.strip
        lastname = data[:lastname]&.strip
        unless firstname.blank? or lastname.blank? # check if mandatory fields are presents
          students["#{firstname&.upcase}##{lastname&.upcase}"] = build_student(students["#{firstname&.upcase}##{lastname&.upcase}"], data, school_id)
        end
      end
  
      students.keys.each do |student|
        create_or_update_student(students[student], school_id)
      end
  
    end
  
    def build_student(already_existing_student, data, school_id)
      student = already_existing_student || {}
      group_name = [data[:classroom_acaweb1], data[:classroom_acaweb2], data[:classroom_acaweb3], data[:classroom_acaweb4], data[:classroom_acaweb5], data[:classroom_acaweb6]].join(' ').strip

      student[:groups] = add_new_group(student[:groups], group_name)
      student[:firstname] = data[:firstname]&.strip&.capitalize
      student[:lastname] = data[:lastname]&.strip&.capitalize 
      new_emails = [data[:email1]&.to_s&.strip, data[:email2]&.to_s&.strip, data[:email3]&.to_s&.strip, data[:email4]&.to_s&.strip, data[:email5]&.to_s&.strip]&.compact&.uniq
      student[:student_emails] = add_new_email(student[:student_emails], new_emails) unless new_emails.blank?
      new_phones = [data[:phone1]&.to_s&.strip, data[:phone2]&.to_s&.strip, data[:phone3]&.to_s&.strip, data[:phone4]&.to_s&.strip, data[:phone5]&.to_s&.strip]&.compact&.uniq
      student[:phones] = add_new_phones(student[:phones], new_phones) unless new_phones.blank?
      student[:school_id] = school_id
      student
    end
  
    def create_or_update_student(data, school_id)
      student = Student.where('lower(firstname) = ? and lower(lastname) = ? and school_id = ?', data[:firstname]&.downcase, data[:lastname]&.downcase, school_id).first
  
      if student.blank?
        new_student = {}
        new_student[:firstname] = data[:firstname]
        new_student[:lastname] = data[:lastname]
        new_student[:school_id] = data[:school_id]
        new_student[:phones] = buildArrayOfPhone(data[:phones]) unless data[:phones].blank?
        new_student[:student_emails] =  buildArrayOfStudentEmail(data[:student_emails]) unless data[:student_emails].blank?
        new_student[:groups] = buildGroupAndGetgroupsIds(data[:groups], school_id)
  
        create_new_student(new_student, school_id)
      else
        student_data = {}
        student_data[:firstname] = data[:firstname]
        student_data[:lastname] = data[:lastname]
        student_data[:idifapme] = data[:idifapme]
        student_data[:phones] = updateArrayOfPhone(student.phones, data[:phones]) if data[:phones]&.any?
        student_data[:student_emails] =  updateArrayOfStudentEmail(student.student_emails, data[:student_emails]) if data[:student_emails]&.any?
        student_data[:groups] = buildGroupAndGetgroupsIds(data[:groups], school_id) if data[:groups]&.any?
  
        update_student(student, student_data, school_id)
      end
    end
  
    def add_new_group(already_existing_groups, group)
      groups = already_existing_groups || []
      groups.push(group&.strip)
      groups.compact.uniq
    end
  
    def add_new_email(already_existing_emails, new_emails)
      emails = already_existing_emails || []
      emails = emails + new_emails
      emails.compact.uniq()
    end
  
    def add_new_phones(already_existing_phones, new_phones)
      phones = already_existing_phones || []
      phones = phones + new_phones
      phones.compact.uniq()
    end
  
  
    private
  
    def update_student(student_to_update, data, school_id)
      student_to_update.update_attributes(data)
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
          write_error_to_firebase(data, new_student.errors, data[:school_id], user_id)
        end
      rescue ActiveRecord::RecordNotUnique => e
        number_of_collision = number_of_collision + 1
        recordUniqueCount = recordUniqueCount + 1
        logger.debug "[collision]: #{new_student.code} for [#{student_key}] #{hash[1]}"
        #key = "#{rand(999999)}#{@student.school_id}#{@student.firstname}#{@student.lastname}"
        new_student.code = 's' + hash[0] + hash[1].last(4 + recordUniqueCount + student_key.length % 3)
        retry
      rescue Exception => e
        logger.info "CreateStudentFromCsvV3Job::Error #{e.inspect}"
        retry
      end
    end
  
    def buildArrayOfPhone(numbers)
      # n.to_s.gsub(/\D/, '') keep only numbers, remove letters
      numbers.compact.map{|n| n.to_s.gsub(/\D/, '')}.uniq.map do |number|
          Phone.new number: number
      end
    end

    def write_error_to_firebase(a, b, c, d)
    end
  
    def updateArrayOfPhone(phones_to_update, new_numbers)
      # keep number already existing
      # add new numbers
      # removes numbers 
      already_existing_numbers = phones_to_update.map{|p| p.number}
  
      new_array_of_numbers = new_numbers || already_existing_numbers
  
      # 1. build an array without number to remove
      new_array_of_phones = phones_to_update.select do |phone|
        new_array_of_numbers.include?(phone.number)
      end
  
      new_array_of_phones + new_numbers.map do |number|
        unless already_existing_numbers.include?(number)
          Phone.new(number: number)
        end
      end.compact
    end
  
    def updateArrayOfStudentEmail(studentemails_to_update, new_emails)
      already_existing_emails = studentemails_to_update.map{|p| p.email}
      
      new_array_of_emails = new_emails || already_existing_emails
  
      new_array_of_studentemails = studentemails_to_update.select do |se|
        new_array_of_emails.include?(se.email)
      end
  
      new_array_of_studentemails + new_emails.map do |email|
        unless already_existing_emails.include?(email)
          StudentEmail.new(email: email)
        end
      end.compact
    end
  
    def buildArrayOfStudentEmail(emails)
      emails.compact.uniq.map do |email|
          StudentEmail.new(email: email) 
      end
    end
  
    def buildGroupAndGetgroupsIds(groups, school_id)
      ids = groups.compact.uniq.map do |group_name|
        Group.find_or_create_group(group_name, school_id, nil).id
      end
  
      # get all_students group
      group_all_students = Group.all_students_by_school(school_id).first
      ids.push(group_all_students.id) unless group_all_students.nil?
  
      ids
    end
  
    # rescue_from(Exception) do |exception|
    #   puts "[CreateStudentFromCsvV2Job info] in rescue_from: #{exception.inspect}"
    #   AlertAdminMailer.send_alert(exception.inspect).deliver_later
    # end
  
    # def failure(job)
    #     puts "[CreateStudentFromCsvV2Job info] in failure: #{job.inspect}"
    #     AlertAdminMailer.send_alert(job.inspect).deliver_later
    # end
  end
  