module Notification extend ActiveSupport::Concern


    def build_ios_notifications(message, devices)
      logger.info "[NOTIFICATION IOS] message(#{message.id} #{message.title}) devices(#{devices.inspect})"

      begin
        puts devicesIOS.inspect
        devicesIOS.each { |device|
          n = Rpush::Apns::Notification.new
          n.app = Rpush::Apns::App.find_by_name("ios_app")
          n.device_token = device.registration_id # 64-character hex string
          n.alert = message.title
          n.data = {
            "title": truncate(message.title, :length => 200),
            "message_id": message.id,
            "content-available": 1,
            "badge": 1
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
          n.registration_ids =
          n.data = { "message_id": message.id }
          n.priority = 'normal'      # Optional, can be either 'normal' or 'high'
          n.content_available = true # Optional
          # Optional notification payload. See the reference below for more keys you can use!
          n.notification = { title: truncate(message.title, :length => 200).force_encoding("utf-8"),
                             icon: 'myicon'
                           }
          n.save!
        end
      rescue => e
        puts "Exception build_android_notifications: #{e}"
      end
    end


end
