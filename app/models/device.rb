class Device < ApplicationRecord

  scope :by_codes, ->(codes) { where("codes && ARRAY[?]::varchar[]", codes) }
  scope :active, -> { where(active: true) }
  scope :android, -> { where(platform: 'Android') }
  scope :ios, -> { where(platform: 'iOS') }

  def disable
    self.update(active: false)
  end

  def self.notify_ios(text, data = nil)
    apn = Houston::Client.production
    apn.certificate = File.read("config/" + Rails.application.secrets.apns_cert_filename) # certificate from prerequisites
    Device.ios.each do |device|
      notification = Houston::Notification.new(device: device.registration_id)
      notification.alert = text
      # take a look at the docs about these params
      notification.badge = 57
      notification.sound = "sosumi.aiff"
      notification.custom_data = data unless data.nil?
      apn.push(notification)
    end
  end

end
