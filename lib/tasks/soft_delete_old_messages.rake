# invokation: rails delete_classroom_for_a_given_school[1]
desc "Soft delete old messages"
task :soft_delete_old_messages => :environment do |task|
  messages = Message.where('updated_at < ? and auto_delete is true', 20.months.ago)
  puts "# de messages à supprimer: " + messages.count
  nbr_images = 0
  messages.each do |message|
    nbr_images += message.photos.count
  #   if message.school&.auto_delete_messages
  #     #message.soft_destroy
  #     #puts "deleting #{message.title} #{message.created_at}"
  #   end
  end
  puts "nbr images: #{nbr_images}"
end
