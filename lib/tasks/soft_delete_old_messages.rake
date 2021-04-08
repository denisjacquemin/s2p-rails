# invokation: rails delete_classroom_for_a_given_school[1]
desc "Soft delete old messages"
task :soft_delete_old_messages => :environment do |task|
  school_ids = School.where('auto_delete_messages is true').pluck(:id)
  messages = Message.where('updated_at < ? and auto_delete is true and deleted is false and school_id IN (?)', 6.months.ago, school_ids)
  nbr_messages_destroy = 0
  nbr_messages_soft_destroy = 0
  nbr_messages_to_keep = 0
  nbr_images = 0
  messages.each do |message|
    nbr_images += message.photos.count
    if message.school.nil?
      nbr_messages_destroy += 1
      message.destroy
    elsif message.school&.auto_delete_messages
      nbr_messages_soft_destroy += 1
      message.soft_destroy
      #puts "deleting #{message.title} #{message.created_at}"
      nbr_images = message.photos.pluck(:public_id).size
    else
      nbr_messages_to_keep += 1
    end
  end
  puts "# de messages to destroy: #{nbr_messages_destroy}"
  puts "# de messages to soft destroy: #{nbr_messages_soft_destroy}"
  puts "# de messages to keep: #{nbr_messages_to_keep}"
  puts "nbr images: #{nbr_images}"
end
