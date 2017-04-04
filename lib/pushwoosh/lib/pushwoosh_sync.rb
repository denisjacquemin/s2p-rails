require "faraday"
API_URL = 'https://cp.pushwoosh.com/json/1.3'

module PushwooshSync

  def self.included(base)
    base.send :include, InstanceMethods
    base.before_destroy :enqueue_remove_device
    base.after_save :enqueue_create_or_update_device, if: "registration_id_changed?"
    base.extend(ClassMethods)
  end

  module ClassMethods
    def pushwoosh_sync_all
      Device.all.each do |device|
        device.create_or_update_device
      end
    end

    def pushwoosh_clean_all
      Device.all.each do |device|
        device.remove_device
      end
    end

    def pushwoosh_create_message(options)
      PushwooshSyncJob.perform_later(options, 'create_message')
    end
  end

  module InstanceMethods
    def enqueue_remove_device
      PushwooshSyncJob.perform_later(self, 'remove_device')
    end

    def enqueue_create_or_update_device
      PushwooshSyncJob.perform_later(self, 'create_or_update_device')
    end

    def create_message(options)
      requestBody = { "request": options }
      response = Faraday.post do |req|
        req.url "#{API_URL}/createMessage"
        req.headers['Content-Type'] = 'application/json'
        req.body = requestBody
      end
    end

    def remove_device
      hwid = self.uuid
      application = ENV["PUSHWOOSH_APPLICATION_CODE"]

      response = Faraday.post do |req|
        req.url "#{API_URL}/unregisterDevice"
        req.headers['Content-Type'] = 'application/json'
        req.body = '{
          "request": {
              "application": "' + application + '",
              "hwid": "' + hwid + '"
          }
        }'
      end
      logger.debug "response: #{response.inspect}"
      logger.debug "call PushWoosh Api async to remove device #{self.inspect}"
    end


    def create_or_update_device
      if not self.uuid.blank? and not self.registration_id.blank?
        hwid = self.uuid || 'no_uuid'
        push_token = self.registration_id || 'no registration_id'
        device_type = self.platform === 'Android'? 3 : 1
        application = ENV["PUSHWOOSH_APPLICATION_CODE"]

        response = Faraday.post do |req|
          req.url "#{API_URL}/registerDevice"
          req.headers['Content-Type'] = 'application/json'
          req.body = '{
            "request": {
                "application": "' + application + '",
                "push_token": "' + push_token + '",
                "language": "' + 'fr' + '",
                "hwid": "' + hwid + '",
                "timezone": ' + 0.to_s + ',
                "device_type": ' + device_type.to_s + '
            }
          }'
        end
        logger.debug "response: #{response.inspect}"
        logger.debug "call PushWoosh Api async to Create or Update device (#{hwid}, #{push_token}, #{device_type})"
      }
    end
  end

  class PushwooshSyncJob < ::ActiveJob::Base
    queue_as :pushwoosh_sync

    def perform(record, method)
      record.send(method)
    end
  end

  class PushwooshAPI

    #- PushWoosh API Documentation http://www.pushwoosh.com/programming-push-notification/pushwoosh-push-notification-remote-api/
    #- Two methods here:
    #     - PushNotification.new.notify_all(message) Notifies all with the same option
    #     - PushNotification.new.notify_devices(notification_options = {}) Notifies specific devices with custom options

    include HTTParty #Make sure to have the HTTParty gem declared in your gemfile https://github.com/jnunemaker/httparty
    default_params :output => 'json'
    format :json

    # def initialize
    #   #- Change to your settings
    #   @auth = {:application  => "00000-00000",:auth => "auth_token"}
    # end

    def registerDevice(hwid)
      options = {
        push_token: hwid
      }

      response = self.class.post("https://cp.pushwoosh.com/json/1.3/registerDevice", :body  => options.to_json,:headers => { 'Content-Type' => 'application/json' })
    end

    # PushNotification.new.notify_all("This is a test notification to all devices")
    def notify_all(message)
      notify_devices({:content  => message})
    end

    # PushNotification.new.notify_device({
    #  :content  => "TEST",
    #  :data  => {:custom_data  => value},
    #  :devices  => array_of_tokens
    #})
    def notify_devices(notification_options = {})
      #- Default options, uncomment :data or :devices if needed
      default_notification_options = {
                          # YYYY-MM-DD HH:mm  OR 'now'
                          :send_date  => "now",
                          # Object( language1: 'content1', language2: 'content2' ) OR string
                          :content  => {
                              :fr  => "Test",
                              :en  => "Test"
                          },
                          # JSON string or JSON object "custom": "json data"
                          #:data  => {
                          #    :custom_data  => value
                          #},
                          # omit this field (push notification will be delivered to all the devices for the application), or provide the list of devices IDs
                          #:devices  => {}
                        }

      #- Merging with specific options
      final_notification_options = default_notification_options.merge(notification_options)

      #- Constructing the final call
      options = @auth.merge({:notifications  => [final_notification_options]})
      options = {:request  => options}
      #- Executing the POST API Call with HTTPARTY - :body => options.to_json allows us to send the json as an object instead of a string
      response = self.class.post("https://cp.pushwoosh.com/json/1.3/createMessage", :body  => options.to_json,:headers => { 'Content-Type' => 'application/json' })
    end
  end

end
