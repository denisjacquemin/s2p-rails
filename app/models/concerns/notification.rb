module Notification extend ActiveSupport::Concern

    def send_message_notifications(message)
      groups_ids = message.groups
      students_ids = message.students

      devices = getDevicesByGroupsAndStudents(groups_ids, students_ids)
      devicesAndroid = devices.android.active
      devicesIOS = devices.ios.active

      if devicesIOS.any?
        dataIOS = {
          "title": truncate(message.title, :length => 200),
          "message_id": message.id,
          "content-available": 1
        }
        send_ios_notifications(message.title, devicesIOS, dataIOS)
      end

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

    def getDevicesByGroupsAndStudents(groups_ids, students_ids)
      # handle groups == nil
      # handle students
      # handle groups
      # handle all_students
      if groups_ids.nil?
        return nil
      else
        students = Student.by_groups(groups_ids).pluck(:code) unless groups_ids.nil?
        students += Student.find(students_ids).pluck(:code) unless students_ids.nil?
        groups = Group.find(groups_ids).pluck(:code)
        # if groups_ids contains all_student, get all students for the targeted schools
        #all_students_groups = Group.where(id: groups_ids, internal_id: 'all_students')
        #alls_students = all_students_groups.map { |g| Student.by_school(g.school_id).pluck(:code)}
        #students += alls_students

        students.uniq!
        Device.by_codes(students + groups)
        # find devices by students.pluck(:code) groups.pluck(:code)
      end

    end


    def send_ios_notifications(alert, devices, data = {})
      logger.info "[NOTIFICATION IOS] message(#{alert}) for devices(#{devices.inspect})"
      begin
        devices.each { |device|
          n = Rpush::Apns::Notification.new
          n.app = Rpush::Apns::App.find_by_name("ios_app")
          n.device_token = device.registration_id # 64-character hex string
          n.alert = truncate(alert, :length => 256)
          n.content_available = true
          n.sound = true
          n.data = data
          begin
            logger.info "[NOTIFICATION IOS TO SEND] + #{n.inspect}"
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
