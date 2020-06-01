
class S2pFirebaseSendMessageJob < ApplicationJob
    queue_as :S2pFirebase
  
    def perform(message)
      studend_ids = Message.find_student_ids(message.groups, message.students, message.school.iscity, message.message_categories)
      if !studend_ids.empty?

        files = message.photos.map do |photo|
          { format: photo.format, path: photo.fullpath }
        end

        data = { 
          'data': {
            'id': message.id,
            'title': message.title,
            'content': message.content,
            'students': studend_ids,
            'files': files,
            'form': message.formdata,
            'muuid': message.muuid
          }   
        }.to_json
  
        begin
          uri = URI(ENV['S2P_FIREBASE_HOST'] + '/sendMessage')
          
          response = Faraday.post do |req|
            req.url uri
            req.headers['Content-Type'] = "application/json; charset=utf-8"
            req.headers['Authorization'] = "Bearer #{ENV['S2P_USERID_FIREBASE_CLOUDFUNCTIONS']}"
            req.body = data
          end
        rescue => e
            puts "[S2PFirebase] #{e}"
        end
      end
    end
  
  end
  