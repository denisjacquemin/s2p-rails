class Message < ApplicationRecord
  include Notification
  include Bulksms
  include Status
  include ActionView::Helpers::TextHelper # for truncate
  include AlgoliaSearch

  monetize :amount_to_pay_cents

  algoliasearch enqueue: true do
    attribute :title, :content, :created_at_ISO8601, :has_form, :author_id, :school_id, :status, :author_fullname, :last_update_meta
    attributesToIndex [:title, :content, :created_at_ISO8601, :has_form, :author_fullname, :school_id]
    #attributesForFaceting [:publish_date, 'searchable(author_fullname)']
    attributesToSnippet ['content:35']
    customRanking ['desc(created_at_ISO8601)']
  end

  has_attachments :photos, accept: [:jpg, :png, :gif, :pdf], maximum: 7

  before_create :generate_uuid

  belongs_to :school, required: false
  has_many :mfiles, dependent: :destroy
  belongs_to :author, class_name: "User"

  scope :by_group, ->(id) { where("? = ANY(groups)", id) }
  scope :by_ids, ->(ids) { where(id: ids) }

  enum mtype: [:message, :rappel]
  enum status: [:draft, :published, :waiting_for_approval, :approval_refused, :approval_accepted, :republished ]
  after_initialize :set_default_status, :if => :new_record?
  after_initialize :set_default_mtype, :if => :new_record?

  validates :title, presence: true
  validate  :presence_of_recipients, if: "status_changed?"

  before_update :avoid_nil_for_status, if: "status_changed?"
  before_update :handle_status_changed, if: "status_changed?"
  before_update :handle_status_republish, if: "status_changed?"

  def publish_date
    publish_date = nil
    publish_date = self.updated_at if self.published?
    return publish_date
  end

  def set_default_status
   self.status ||= :draft
  end

  def set_default_mtype
    self.mtype ||= :message
  end

  def created_at_ISO8601
    self.created_at.utc.iso8601
  end

  def has_form
    not (self.formdata.blank? or self.formdata === "[]")
  end

  def last_update_meta
    if self.published?
      return "Publié le #{I18n.l(self.publish_date.to_datetime().in_time_zone, format: :short)}"
    else
      return "Dernière mise à jour le #{I18n.l(self.updated_at.to_datetime().in_time_zone, format: :short)}"
    end
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
    logger.info ">>> in Message.handle_status_changed"
    if (self.status != self.status_was)
      case self.status
        when 'republished'
          handle_repuplish
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
  end

  def handle_status_republish
    self.status = 'published' if republished?
  end

  def handle_repuplish
    handle_publish
  end

  def handle_publish
    groups = self.groups
    if groups.present? or self.students.present?

      send_message_notifications(self) if self.send_to_app

      students = Student.includes(:phones).by_groups(groups) unless groups.nil?
      students = students + Student.includes(:phones).find(self.students) unless self.students.nil?
      students = students.uniq
      # student_codes = students.map {|s| s.code }
      # codes = (student_codes +  Group.find(groups).pluck(:code)).flatten
      #
      # devicesIOS = Device.active.ios.by_codes(codes)
      # build_ios_notifications(self, devicesIOS) if self.send_to_app

      #@message.notify_ios(devicesIOS, truncate(@message.title, :length => 200))

      # devicesAndroid = Device.active.android.by_codes(codes)
      # build_android_notifications(self, devicesAndroid) if self.send_to_app
      if self.send_by_sms and self.school.has_sms_provision?
        logger.info "send_by_sms: #{students.inspect}"
        phones = students.select {|s|  s.phones.present?}.map {|s| s.phones.select(:id, :number)}.flatten.compact.uniq

        phones.each_slice(40) {|a| SendSmsJob.perform_later(self, a)}
      end

      # if group "Tous les redacteurs" is selected gets all redactors' emails
      writers_emails = []
      if groups.include?(Group.where(internal_id: 'all_writers', school_id: self.school_id).pluck(:id).first)
        writers_emails = User.by_school(self.school_id).no_superadmin.active.pluck(:email)
      end

      build_emails(students, self, self.title, self.content, writers_emails) if self.send_by_email and (students.present? or writers_emails.present?)
    end
  end

  def handle_draft
    # self.publish_date = nil
  end

  def handle_waiting_for_approval
    self.wfa_sms_sent = false
    self.aa_sms_sent = false
    self.ar_sms_sent = false
    # codes = self.school.admins.map{|u| u.code}
    # phone_numbers = self.school.admins.map{|u| u.phone}
    # alert = "#{self.author.firstname} demande une approbation: #{self.title}"
    # SendSmsJob.perform_later(alert, phone_numbers,)
    #
    # devicesIOS = Device.active.ios.by_codes(codes)

    # data = { "message_id": self.id }
    # send_ios_notifications(alert, "", devicesIOS, data) unless devicesIOS.nil?
    # devicesAndroid = Device.active.android.by_codes(codes)
    #
    # dataAndroid = {
    #   "priority": 2,
    #   "title": alert,
    #   "visibility": 1 # public
    # }
    # send_android_notifications(alert, devicesAndroid, dataAndroid) unless devicesAndroid.nil?
  end

  def handle_approval_refused
    # codes = [] <<  self.author.code
    #
    # devicesIOS = Device.active.ios.by_codes(codes)
    # alert = "Message refusé: #{self.title}"
    # send_ios_notifications(alert, "", devicesIOS) unless devicesIOS.nil?
    # devicesAndroid = Device.active.android.by_codes(codes)
    # dataAndroid = {
    #   "priority": 2,
    #   "title": alert,
    #   "visibility": 1 # public
    # }
    # send_android_notifications(alert, devicesAndroid, dataAndroid) unless devicesAndroid.nil?
  end

  def handle_approval_accepted
    # codes = [] <<  self.author.code
    #
    # devicesIOS = Device.active.ios.by_codes(codes)
    # alert = "Message approuvé: #{self.title}"
    # send_ios_notifications(alert, "", devicesIOS) unless devicesIOS.nil?
    # devicesAndroid = Device.active.android.by_codes(codes)
    # dataAndroid = {
    #   "priority": 2,
    #   "title": alert,
    #   "visibility": 1 # public
    # }
    # send_android_notifications(alert, devicesAndroid, dataAndroid) unless devicesAndroid.nil?
  end

  def build_emails(students, message, title, content, writers_emails=[])
    emails = students.collect { |s|
      s.emails.split(' ') if (s.sent_message_by_email or message.skip_send_by_email) and !s.emails.nil?
    }      # build an array of emails

   # content = message.content
    emails.push(message.author_email) unless message.author_email.blank?
    message.admins_emails.each {|e| emails.push(e)} unless message.admins_emails.blank?
    emails.push(writers_emails)

    emails = emails.compact.flatten.uniq
    # if message.content.include?('[code]')
    #   sub = emails.each |email| do
    #     For current email gets all students to build the codes
    #     codes = Student.by_email(email).collect |student| do
    #       "<li>#{student.fullname}: #{student.code}</li>"
    #     end
    #
    #   end
    MessageMailer.message_email(emails, message, title, content).deliver_later

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

  # payconiq related code
  # doc available at https://dev.payconiq.com/online-payments-dock

  def pq_create_transaction(amount_in_cents, description="", callbackUrl=Rails.application.secrets.payconiq_callback_url, currency='EUR' )

    url = URI.parse(Rails.application.secrets.payconiq_host)

    headers = {
      'Content-Type': 'application/json',
      'authorization': Rails.application.secrets.payconiq_access_token,
      'cache-control': 'no-cache'
    }
    req = Net::HTTP::Post.new(url.path, headers)

    data = {
      "amount": amount_in_cents,
      "currency": currency,
      "callbackUrl": callbackUrl,
      "description": description
      # "signature": 'io+eRjK6B9yO4fzijU0p4CCtdol3XCypPXoluKErM0E=',
    }
    req.body = data.to_json

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    response = http.request(req)
    return JSON.parse(response.body)['transactionId'] if response.kind_of? Net::HTTPSuccess
    return JSON.parse(response.body)['message'] unless response.kind_of? Net::HTTPError
  end


  # def get_students_names_by_email(email)
  #
  #   # for a given email, find student's names targeted for that message
  #   students_by_email = Student.by_email(email) # gets all students for a given email
  #
  #   # then keep only students targeted by the message based on message.groups ans message.students
  #   students_names = students_by_email.each do |student|
  #     gic = false
  #     gic = group_in_common?(student.groups, self.groups) if (self.groups.present?)
  #
  #     s_contained_in_m = false
  #     s_contained_in_m = self.students.include?(s.id) if (self.students.present?)
  #
  #     s.fullname if (gic or s_contained_in_m)
  #   end
  # end

  private

  # def group_in_common?(student_groups, message_groups)
  #   sg = student_groups || []
  #   mg = message_groups || []
  #   (sg & mg).any?
  # end

  def generate_uuid
    self.muuid = SecureRandom.uuid
  end

  def avoid_nil_for_status
    if status.blank?
      status = status_was # keep current value if new value is nil
    end
  end

  def presence_of_recipients
    if status == 'published' and students.blank? and groups.blank?
      errors.add(:base, "La liste des destinataires est vide")
    end
  end
end
