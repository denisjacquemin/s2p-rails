desc "Read Feedback table and update Device table"
task :handle_feedback => :environment do
  puts "Reading Feedback"
  feedbacks = Rpush::Apns::Feedback.all
  feedbacks.each do |feedback|
    device = Device.find_by_token(feedback.device_token)
    unless device.nil?
      puts "disable device #{device.token}"
      device.disable
    end
    puts "delete feeback for token #{feedback.device_token}"
    feedback.delete
  end
end
