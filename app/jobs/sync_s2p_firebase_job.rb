
class SyncS2pFirebaseJob < ApplicationJob
  queue_as :S2pFirebase

  def perform(message)

    devices = getDevicesByGroupsAndStudents(message.groups, message.students)

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
          'muuid': message.muuid,
          'tokens': devices.pluck(:registration_id).flatten
        }   
      }.to_json

      begin
        uri = URI(ENV['S2P_FIREBASE_HOST'] + '/addMessage')
        response = Faraday.post do |req|
          req.url uri
          req.headers['Content-Type'] = "application/json; charset=utf-8"
          req.headers['Authorization'] = "Bearer #{ENV['S2P_USERID_FIREBASE_CLOUDFUNCTIONS']}"
          req.body = data
        end
      rescue => e
          puts "failed #{e}"
      end
    end
  end

  private

  def getDevicesByGroupsAndStudents(groups_ids, students_ids)
    # handle groups == nil
    # handle students
    # handle groups
    # handle all_students
    students = []
    if groups_ids.empty? && students_ids.empty?
      return []
    else
      students = Student.by_groups(groups_ids).pluck(:code) unless groups_ids.nil? || groups_ids.empty?
      students += Student.find(students_ids).pluck(:code) unless students_ids.nil? || students_ids.empty?
      # if groups_ids contains all_student, get all students for the targeted schools
      #all_students_groups = Group.where(id: groups_ids, internal_id: 'all_students')
      #alls_students = all_students_groups.map { |g| Student.by_school(g.school_id).pluck(:code)}
      #students += alls_students

      students.uniq!
      Device.by_codes(students)
      # find devices by students.pluck(:code) groups.pluck(:code)
    end

  end

end
