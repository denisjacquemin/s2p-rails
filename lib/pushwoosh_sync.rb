module PushwooshSync

  def self.included(base)
    base.send :include, InstanceMethods
    base.before_destroy :enqueue_remove_device
    base.after_save :create_or_update_device, if: "registration_id_changed?"
    base.extend(ClassMethods)
  end

  module ClassMethods
    def pushwoosh_sync_all
      Device.all.each do |device|
        device.create_or_update_device
      end
    end
  end

  module InstanceMethods
    def enqueue_remove_device
      logger.debug "Enqueue remove device from pushwoosh"
      PushwooshSyncJob.perform_later(self, 'remove_device')
    end

    def remove_device
      logger.debug "call PushWoosh Api async to remove device #{self.inspect}"
    end

    def enqueue_create_or_update_device
      logger.debug "Enqueue create or update device from pushwoosh"
      PushwooshSyncJob.perform_later(self, 'create_or_update_device')
    end

    def create_or_update_device
      hwid = self.uuid
      new_push_token = self.registration_id
      device_type = self.platform === 'Android'? 3 : 1
      logger.debug "call PushWoosh Api async to Create or Update device (#{hwid}, #{new_push_token}, #{device_type})"
    end


  end

  class PushwooshSyncJob < ::ActiveJob::Base
    queue_as :pushwoosh_sync

    def perform(record, method)
      record.send(method)
    end
  end

end
