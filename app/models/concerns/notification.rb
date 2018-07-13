module Notification extend ActiveSupport::Concern

    def send_message_notifications(message)
      groups_ids = message.groups
      students_ids = message.students

      devices = []
      if message.school.iscity?
        devices = getDevicesByGroupsAndStudentsFilterByCategories(groups_ids, students_ids, message.message_categories.pluck(:id))
      else
        devices = getDevicesByGroupsAndStudents(groups_ids, students_ids)
      end
      logger.error "[PW] devices: #{devices.inspect}"

      devicesAndroid = devices.android
      devicesIOS = devices.ios
      if devicesIOS.any?
        dataIOS = {
          "title": truncate(message.title, :length => 200),
          "message_id": message.id,
          "content-available": 1,
          "notId": message.id
        }
        send_ios_notifications(message.title, ActionController::Base.helpers.strip_tags(message.content)[0..150], devicesIOS, dataIOS)

        # options = {
        #   "application": ENV["PUSHWOOSH_APPLICATION_CODE"],
        #   "auth": ENV["PUSHWOOSH_API_TOKEN"],
        #   "notifications": [{
        #       "send_date": "now", # YYYY-MM-DD HH:mm  OR 'now'
        #       "ignore_user_timezone": true, # or false
        #       "content": message.title,
        #       "platforms": [1],
        #       "devices": devicesIOS.pluck(:registration_id)
        #   }]
        # }
        # Device.pushwoosh_create_message(options)
      else
        logger.info "No IOS notification to send #{devices.inspect} "
      end

      logger.info "Number Android devices found: #{devicesAndroid.inspect}"
      if devicesAndroid.any?
        dataAndroid = {
          "message_id": message.id,
          "notId": message.id,
          "priority": 2,
          "title": truncate(message.title, :length => 200),
          "message": truncate(ActionController::Base.helpers.strip_tags(message.content), :length => 250),
          "badge": 1,
          "content-available": "1",
          "visibility": 1 # public
        }
        send_android_notifications(message.title, devicesAndroid, dataAndroid)
      end

    end

    # def send_notification_with_pushwoosh(message)
    #
    #   other_options = {
    #     'content': message.title,
    #     'send_date': "now",
    #     'ios_badges': "+1",
    #     'platforms': [1, 3]
    #   }
    #   other_options = {}
    #   # pwdevices = devicesAndroid + devicesIOS
    #   # logger.info "[PW] devicesIOS: #{devicesIOS.inspect}"
    #   resp = Pushwoosh.notify_devices("PW: #{message.title}", ["78100f94d0178e63a2619754ae288df737af38497285e929e82bdc1ba6bae101"], other_options)
    #   logger.error "[PW] after Pushwoosh.notify_devices: #{resp.inspect}"
    # end

    def getDevicesByGroupsAndStudents(groups_ids, students_ids)
      # handle groups == nil
      # handle students
      # handle groups
      # handle all_students
      students = []
      if groups_ids.empty? && students_ids.empty?
        return []
      else
        students = Student.by_groups(groups_ids).pluck(:code) unless groups_ids.nil? || groups_ids.empty?
        students += Student.find(students_ids).pluck(:code) unless students_ids.nil? || students_ids.empty?
        # if groups_ids contains all_student, get all students for the targeted schools
        #all_students_groups = Group.where(id: groups_ids, internal_id: 'all_students')
        #alls_students = all_students_groups.map { |g| Student.by_school(g.school_id).pluck(:code)}
        #students += alls_students

        students.uniq!
        Device.by_codes(students)
        # find devices by students.pluck(:code) groups.pluck(:code)
      end

    end

    def getDevicesByGroupsAndStudentsFilterByCategories(groups_ids, students_ids, message_categories)
      students = []
      if groups_ids.empty? && students_ids.empty?
        return []
      else
        students = Student.by_groups(groups_ids) unless groups_ids.nil? || groups_ids.empty?
        students += Student.find(students_ids) unless students_ids.nil? || students_ids.empty?
        # filter by categories
        students_filtered = students.select do |student|
          (message_categories & student.message_categories.pluck(:id)).any?
        end
        students_codes_filtered = students_filtered.pluck(:code)
        students_codes_filtered.uniq!
        return Device.by_codes(students_codes_filtered)
      end
    end


    def send_ios_notifications(alert, content, devices, data = {})
      logger.info "[NOTIFICATION IOS] message(#{alert}) for devices(#{devices.inspect})"
      begin
        devices.each { |device|
          n = Rpush::Apns::Notification.new
          n.app = Rpush::Apns::App.find_by_name("ios_app")
          n.device_token = device.registration_id # 64-character hex string
          n.alert = {
            title: alert[0..256],
            body: content[0..256]
          }
          n.content_available = true
          expiry_value = Time.now + 2.day
          n.expiry = expiry_value.to_i
          n.badge = 1
          n.sound = true
          n.data = data

# {
#   "aps": {
#     "alert":"Visite du château de Bouillion",
#     "sound":"t",
#     "content-available":1
#   },
#   "title":"Visite du château de Bouillion",
#   "message_id":82,
#   "content-available":1}

          begin
            logger.info "[NOTIFICATION IOS TO SEND] + #{n.inspect} + payload: #{n.payload}"
            n.save!
          rescue ActiveRecord::RecordInvalid
            logger.info "[NOTIFICATION IOS FAILED] Rpush::Apns::Notification save failed for #{device.token} + #{device.inspect}"
          end
        }
      rescue => e
        logger.error "Exception send_ios_notifications: #{e}"
      end
    end

    def send_android_notifications(alert, devices, data = {})
      logger.info "[NOTIFICATION ANDROID] message(#{alert}) devices(#{devices.inspect})"
      begin
        registration_ids = devices.map{|device| device.registration_id}
        unless registration_ids.nil?
          n = Rpush::Gcm::Notification.new
          n.app = Rpush::Gcm::App.find_by_name("android_app")
          n.registration_ids = registration_ids
          n.delay_while_idle = true
          n.data = data
          n.save!
          logger.info "payload: #{n.payload}"
        end
      rescue => e
        puts "Exception send_android_notifications: #{e}"
      end
    end


    def build_ios_notifications(message, devices)
      logger.info "[NOTIFICATION IOS] message(#{message.id} #{message.title}) devices(#{devices.inspect})"
      begin
        devices.each { |device|
          n = Rpush::Apns::Notification.new
          n.app = Rpush::Apns::App.find_by_name("ios_app")
          n.device_token = device.registration_id # 64-character hex string
          n.alert = message.title
          n.data = {
            "title": truncate(message.title, :length => 200),
            "message_id": message.id,
            "content-available": 1
          }
          begin
            n.save!
          rescue ActiveRecord::RecordInvalid
            logger.debug "Rpush::Apns::Notification save failed for #{device.token} + #{device.inspect}"
          end
        }
      rescue => e
        logger.error "Exception build_ios_notifications: #{e}"
      end
    end

    def build_android_notifications(message, devices)
      logger.info "[NOTIFICATION ANDROID] message(#{message.id} #{message.title}) devices(#{devices.inspect})"
      begin
        registration_ids = devices.map{|device| device.registration_id}
        unless registration_ids.nil?
          n = Rpush::Gcm::Notification.new
          n.app = Rpush::Gcm::App.find_by_name("android_app")
          n.registration_ids = registration_ids
          n.delay_while_idle = true
          n.data = {
            "message_id": message.id,
            "notId": message.id,
            "priority": 2,
            "title": truncate(message.title, :length => 200),
            "message": truncate(ActionController::Base.helpers.strip_tags(message.content), :length => 250),
            "content-available": "1",
            "visibility": 1 # public
          }
          #n.priority = 'normal'      # Optional, can be either 'normal' or 'high'
          #n.content_available = true # Optional
          # Optional notification payload. See the reference below for more keys you can use!
          #n.notification = { title: truncate(message.title, :length => 200).force_encoding("utf-8"),
          #                   icon: 'myicon'
          #                 }
          n.save!
          logger.info "payload: #{n.payload}"
        end
      rescue => e
        puts "Exception build_android_notifications: #{e}"
      end
    end


end
