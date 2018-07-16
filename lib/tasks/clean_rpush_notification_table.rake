desc "Cleaning rpush_notifications table"
task :clean_rpush_notifications_table => :environment do
  ActiveRecord::Base.logger = Logger.new(STDOUT)

  # gets all IOS notifications older than 2 weeks
  ios_notifications = Rpush::Apns::Notification.where("created_at < ?", 2.weeks.ago)

  # gets all Android notifications older than 2 weeks
  android_notifications = Rpush::Gcm::Notification.where("created_at < ?", 2.weeks.ago)

  ios_notifications.delete_all
  android_notifications.delete_all
end
