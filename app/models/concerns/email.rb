module Email extend ActiveSupport::Concern

    def sendMessageByEmail(message, delivery_method)
        # if they are at least something to send
        if message.groups.present? or message.students.present?
            student_ids = find_student_ids(message.groups, message.students, message.school.iscity?, message.message_categories.pluck(:id))

            # if group "Tous les redacteurs" is selected gets all redactors' emails
            writers_emails = []
            if message.groups.include?(Group.where(internal_id: 'all_writers', school_id: message.school_id).pluck(:id).first)
                writers_emails = User.by_school(message.school_id).no_superadmin.active.pluck(:email)
            end

            emails_data = build_emails(student_ids, message, message.title, message.content, writers_emails) if student_ids.present? or writers_emails.present?

            sendEmails(emails_data, message, delivery_method)
        end
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

    def build_emails(student_ids, message, title, content, writers_emails=[])
        # building emails required to build 3 arrays
        # 1. emails
        # 2. codes: for each email set the code (in li tags)
        # 3. emails_encrypt: for each email encrypt the email
        # for emails without code ei: admins and author set an empty string
        emails_data = {}
    
        students = Student.joins(:student_emails).where(id: student_ids).pluck( :sent_message_by_email, :firstname, :lastname, :code, :"student_emails.email", :id)
        students.each do |student|
          if (student[0] or message.skip_send_by_email)
            emails_data = add_to_hash_and_merge_code(emails_data, student[4], "<li>#{student[1]} #{student[2]}: #{student[3]}</li>", student[5])
          end
        end
    
        # add author
        if message.author.send_email_to_author? and not message.author_email.blank?
          emails_data = add_to_hash_and_merge_code(emails_data, message.author_email)
        end
        # add admins
        unless message.admins_emails.blank?
          message.admins_emails.each { |email|
            emails_data = add_to_hash_and_merge_code(emails_data, email)
          }
        end
        # add writers (redacteurs)
        unless writers_emails.blank?
          writers_emails.each { |email|
            emails_data = add_to_hash_and_merge_code(emails_data, email)
          }
        end

        return emails_data
        
        
    end

    def sendEmails(emails_data, message, delivery_method = 'later')
        unless emails_data.blank?
            chunck_size = 20
      
            index = 0
            array_to_process = []
            emails_data.each_value do |value|
              array_to_process.push(value)
              index= index+1
              if index == chunck_size
                index = 0
                MessageMailer.message_email(array_to_process, message, message.title, message.content).deliver_later if delivery_method == 'later'
                MessageMailer.message_email(array_to_process, message, message.title, message.content).deliver_now if delivery_method == 'now'
                array_to_process = []
              end
            end
            # process latest if any
            unless array_to_process.empty?
                MessageMailer.message_email(array_to_process, message, message.title, message.content).deliver_later if delivery_method == 'later'
                MessageMailer.message_email(array_to_process, message, message.title, message.content).deliver_now if delivery_method == 'now'
            end
        end
    end

    def add_to_hash_and_merge_code(hash, email, codeTag="", student_id="")

        code = codeTag
        code = "#{hash[email][:code]}#{codeTag}" if hash.key?(email)
        hash[email] = {
          email: email,
          email_encrypted: email, #"ed", #Student.email_encrypt(email)
          student_id: student_id&.to_s,
          code: code
        }
        hash
    end
end