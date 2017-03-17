class Message < ApplicationRecord
  include Notification
  include Status
  include ActionView::Helpers::TextHelper # for truncate
  include AlgoliaSearch

  algoliasearch do
    attribute :title, :content, :publish_date, :author_id, :school_id, :status, :author_fullname
    attributesToIndex [:title, :content, :publish_date, :author_fullname, :status]
    attributesForFaceting [:publish_date, 'searchable(author_fullname)']
    attributesToSnippet ['content:22']
  end

  has_attachments :photos, accept: [:jpg, :png, :gif]

  before_create :generate_uuid

  belongs_to :school, required: false
  has_many :mfiles, dependent: :destroy
  belongs_to :author, class_name: "User"

  scope :by_group, ->(id) { where("? = ANY(groups)", id) }
  scope :by_ids, ->(ids) { where(id: ids) }

  enum mtype: [:message, :rappel]
  enum status: [:draft, :published, :waiting_for_approval, :approval_refused, :approval_accepted ]
  after_initialize :set_default_status, :if => :new_record?
  after_initialize :set_default_mtype, :if => :new_record?

  validates :mtype, presence: true
  validates :title, presence: true

  before_update :handle_status_changed, if: "status_changed?"

  def set_default_status
   self.status ||= :draft
  end

  def set_default_mtype
    self.mtype ||= :message
  end

  def author_fullname
    fullname = ""
    fullname = "#{self.author.firstname} #{self.author.lastname}" if self.author
    return fullname
  end

  def groups_obj
    Group.by_ids(self.groups)
  end

  def students_obj
    Student.by_ids(self.students)
  end

  def self.add_groups(message_ids, group_ids)
    Message.by_ids(message_ids).update_all(['groups = array_cat(groups, ARRAY[?]), updated_at = ?', group_ids, Time.now.utc])
  end

  def self.remove_groups(message_ids, group_ids)
    group_ids.each do |g_id|
      Message.by_ids(message_ids).update_all(['groups = array_remove(groups, ?), updated_at = ?', g_id, Time.now.utc])
    end
  end

  def self.remove_group(message_ids, group_id)
    Message.by_ids(message_ids).update_all(['groups = array_remove(groups, ?)', group_id])
  end

  def handle_status_changed
    case self.status
      when 'published'
        handle_publish
      when 'draft'
        handle_draft
      when 'waiting_for_approval'
        handle_waiting_for_approval
      when 'approval_refused'
        handle_approval_refused
      when 'approval_accepted'
        handle_approval_accepted
    end
  end

  def handle_publish
    self.publish_date = DateTime.now
    groups = self.groups
    if groups.present? or self.students.present?

      send_message_notifications(self) if self.send_to_app


      students = Student.by_groups(groups) unless groups.nil?
      students = students + Student.find(self.students) unless self.students.nil?
      students = students.uniq
      # student_codes = students.map {|s| s.code }
      # codes = (student_codes +  Group.find(groups).pluck(:code)).flatten
      #
      # devicesIOS = Device.active.ios.by_codes(codes)
      # build_ios_notifications(self, devicesIOS) if self.send_to_app

      #@message.notify_ios(devicesIOS, truncate(@message.title, :length => 200))

      # devicesAndroid = Device.active.android.by_codes(codes)
      # build_android_notifications(self, devicesAndroid) if self.send_to_app
      build_emails(students, self) if self.send_by_email and students.present?
    end
  end

  def handle_draft
    self.publish_date = nil
  end

  def handle_waiting_for_approval
    codes = self.school.admins.map{|u| u.code}

    devicesIOS = Device.active.ios.by_codes(codes)
    alert = "#{self.author.firstname} demande une approbation: #{self.title}"
    data = { "message_id": self.id }
    send_ios_notifications(alert, devicesIOS, data) unless devicesIOS.nil?
    devicesAndroid = Device.active.android.by_codes(codes)

    dataAndroid = {
      "priority": 2,
      "title": alert,
      "visibility": 1 # public
    }
    send_android_notifications(alert, devicesAndroid, dataAndroid) unless devicesAndroid.nil?
  end

  def handle_approval_refused
    codes = [] <<  self.author.code

    devicesIOS = Device.active.ios.by_codes(codes)
    alert = "Message refusé: #{self.title}"
    send_ios_notifications(alert, devicesIOS) unless devicesIOS.nil?
    devicesAndroid = Device.active.android.by_codes(codes)
    dataAndroid = {
      "priority": 2,
      "title": alert,
      "visibility": 1 # public
    }
    send_android_notifications(alert, devicesAndroid, dataAndroid) unless devicesAndroid.nil?
  end

  def handle_approval_accepted
    codes = [] <<  self.author.code

    devicesIOS = Device.active.ios.by_codes(codes)
    alert = "Message approuvé: #{self.title}"
    send_ios_notifications(alert, devicesIOS) unless devicesIOS.nil?
    devicesAndroid = Device.active.android.by_codes(codes)
    dataAndroid = {
      "priority": 2,
      "title": alert,
      "visibility": 1 # public
    }
    send_android_notifications(alert, devicesAndroid, dataAndroid) unless devicesAndroid.nil?
  end

  def build_emails(students, message)
    emails = students.collect { |s|
      s.emails.split(' ') if (s.sent_message_by_email or message.skip_send_by_email) and !s.emails.nil?
    }      # build an array of emails

   # content = message.content
    emails.push(message.author_email) unless message.author_email.blank?
    message.admins_emails.each {|e| emails.push(e)} unless message.admins_emails.blank?
    emails = emails.compact.flatten.uniq
    # if message.content.include?('[code]')
    #   sub = emails.each |email| do
    #     For current email gets all students to build the codes
    #     codes = Student.by_email(email).collect |student| do
    #       "<li>#{student.fullname}: #{student.code}</li>"
    #     end
    #
    #   end
    MessageMailer.message_email(emails, message).deliver_later

    # emails.each do |e|
    #   message.content = replace_code_smart_tag(students, e, content) if content.include?('[code]')
    #   MessageMailer.message_email(e, message).deliver_later
    # end
    #message.content = content
  end

  def author_email
    if self.author.nil? or self.author.email.blank?
      return nil
    else
      return self.author.email
    end
  end

  def admins_emails
    if self.school.nil? or self.school.admins.blank?
      return nil
    else
      return self.school.admins.pluck(:email)
    end
  end

  def school_name
    if self.school.nil? or self.school.name.blank?
      return nil
    else
      return self.school.name
    end
  end

  def replace_code_smart_tag(students, email, content)
    codes = ""
    students.each do |s|
      #puts "#{s.code} found for student #{s.fullname} and email #{email} $$$$ (#{s.inspect})"
      codes << "<li>#{s.fullname}: #{s.code}</li>" if s.emails.present? and s.emails.include?(email)
    end

    content.gsub('[code]', "<ul>#{codes}</ul>")
  end

  def self.recipients_groups(school, user)
    if user.admin?
      Group.by_school(school.id)
    else # user is a writer
      user.groups.by_school(school.id)
    end
  end
  def self.recipients_students(school, user)
    if user.admin?
      Student.by_school(school.id)
    else # user is a writer
      user.students.by_school(school.id)
    end
  end

  private

  def generate_uuid
    self.muuid = SecureRandom.uuid
  end
end
