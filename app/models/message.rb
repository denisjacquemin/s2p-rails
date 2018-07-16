class Message < ApplicationRecord
  include Notification
  include Bulksms
  include Status
  include ActionView::Helpers::TextHelper # for truncate
  include AlgoliaSearch

  monetize :amount_to_pay_cents

  algoliasearch sanitize: true do
    attribute :title, :created_at_ISO8601, :has_form, :author_id, :school_id, :status, :author_fullname, :last_update_meta

    attribute :content do
      content.truncate(5000)
    end

    attributesToIndex [:title, :content, :created_at_ISO8601, :has_form, :author_fullname, :school_id]



    #attributesForFaceting [:publish_date, 'searchable(author_fullname)']
    attributesToSnippet ['content:35']
    customRanking ['desc(created_at_ISO8601)']
  end

  has_attachments :photos, accept: [:jpg, :png, :gif, :pdf], maximum: 7

  before_create :generate_uuid

  belongs_to :school, required: false
  has_many :mfiles, dependent: :destroy
  has_and_belongs_to_many :message_categories
  belongs_to :author, class_name: "User"
  has_many :billed_students
  accepts_nested_attributes_for :billed_students
  belongs_to :account

  has_many :succeeded_payments, -> { succeeded }, class_name: "Payment"


  scope :by_group, ->(id) { where("? = ANY(groups)", id) }
  scope :by_ids, ->(ids) { where(id: ids) }

  enum mtype: [:message, :rappel]
  enum status: [:draft, :published, :waiting_for_approval, :approval_refused, :approval_accepted, :republished ]
  after_initialize :set_default_status, :if => :new_record?
  after_initialize :set_default_mtype, :if => :new_record?

  validates :title, presence: true
  validate  :presence_of_recipients, if: -> {status_changed?}

  before_update :avoid_nil_for_status, if: -> {status_changed?}
  before_update :handle_status_changed, if: -> {status_changed?}
  before_update :handle_status_republish, if: -> {status_changed?}

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
    Student.default_order.by_ids(self.students)
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
      # students = Student.includes([:phones, :student_emails]).by_groups(groups) unless groups.nil?
      #
      # students = students + Student.includes([:phones, :student_emails]).find(self.students) unless self.students.nil?
      #
      # students = students.uniq


      # student_codes = students.map {|s| s.code }
      # codes = (student_codes +  Group.find(groups).pluck(:code)).flatten
      #
      # devicesIOS = Device.active.ios.by_codes(codes)
      # build_ios_notifications(self, devicesIOS) if self.send_to_app

      #@message.notify_ios(devicesIOS, truncate(@message.title, :length => 200))

      # devicesAndroid = Device.active.android.by_codes(codes)
      # build_android_notifications(self, devicesAndroid) if self.send_to_app

      student_ids = build_student_ids(groups, self.students, self.school.iscity?, self.message_categories.pluck(:id))
      # StudentsByMessagePublishJob.perform_later(student_ids, self.id, self.school_id)
      if self.send_by_sms and self.school.has_sms_provision?
        logger.info "send_by_sms: #{students.inspect}"
        # phones = students.select {|s|  s.phones.present?}.map {|s| s.phones.select(:id, :number)}.flatten.compact.uniq
        phones = Student.joins(:phones).where(id: student_ids).pluck( :id, :"phones.number")
        phones.each_slice(40) {|a| SendSmsJob.perform_later(self, a)}
      end

      # if group "Tous les redacteurs" is selected gets all redactors' emails
      writers_emails = []
      if groups.include?(Group.where(internal_id: 'all_writers', school_id: self.school_id).pluck(:id).first)
        writers_emails = User.by_school(self.school_id).no_superadmin.active.pluck(:email)
      end
      build_emails(student_ids, self, self.title, self.content, writers_emails) if self.send_by_email and (student_ids.present? or writers_emails.present?)
    end
  end

  def build_student_ids(groups, student_ids, iscity, message_categories)
    ids = []
    ids = student_ids if student_ids.present?
    ids = ids + Student.by_groups(groups).pluck(:id) if groups.present?

    # if iscity then filter on categories
    if iscity
      ids_filtered = ids.select do |id|
        student_categories = Student.where(id: id).joins(:message_categories).pluck("message_categories.id")
        (student_categories & message_categories).any?
      end
      return ids_filtered.uniq
    else
      return ids.uniq
    end
  end

  def handle_draft
    # self.publish_date = nil
  end

  def handle_waiting_for_approval
    self.wfa_sms_sent = false
    self.aa_sms_sent = false
    self.ar_sms_sent = false
    admin_emails = self.school.admins.wants_email_notification.map{|u| u.email}
    NotificationMailer.approval_requested(admin_emails, self.title, self.author.firstname, self.author.lastname).deliver_later unless admin_emails.empty?

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
  def build_emails(student_ids, message, title, content, writers_emails=[])
    # building emails required to build 3 arrays
    # 1. emails
    # 2. codes: for each email set the code (in li tags)
    # 3. emails_encrypt: for each email encrypt the email
    # for emails without code ei: admins and author set an empty string
    emails_data = {}

    students = Student.joins(:student_emails).where(id: student_ids).pluck( :sent_message_by_email, :firstname, :lastname, :code, :"student_emails.email", :id)

    students.each do |student|
      if (student[0] or message.skip_send_by_email)
        emails_data = add_to_hash_and_merge_code(emails_data, student[4], "<li>#{student[1]} #{student[2]}: #{student[3]}</li>", student[5])
      end
    end

    # add author
    if message.author.send_email_to_author? and not message.author_email.blank?
      emails_data = add_to_hash_and_merge_code(emails_data, message.author_email)
    end
    # add admins
    unless message.admins_emails.blank?
      message.admins_emails.each { |email|
        emails_data = add_to_hash_and_merge_code(emails_data, email)
      }
    end
    # add writers (redacteurs)
    unless writers_emails.blank?
      writers_emails.each { |email|
        emails_data = add_to_hash_and_merge_code(emails_data, email)
      }
    end

    unless emails_data.blank?
      chunck_size = 100

      index = 0
      array_to_process = []
      emails_data.each_value do |value|
        array_to_process.push(value)
        index= index+1
        if index == chunck_size
          index = 0
          MessageMailer.message_email(array_to_process, message, title, content).deliver_later
          array_to_process = []
        end
      end
      # process latest if any
      MessageMailer.message_email(array_to_process, message, title, content).deliver_later unless array_to_process.empty?

      # emails_dataChucked = emails_data.each_slice(chuckSize).to_a
      # index = 0
      # array_to_process = []
      # emails_dataChucked.each do |email_data|
      #   array_to_process.push(email_data)
      #   index++
      #   if index == chunck_size
      #     index = 0
      #     MessageMailer.message_email(array_to_process, message, title, content).deliver_later
      #     array_to_process = []
      # end
    end

  end

  def add_to_hash_and_merge_code(hash, email, codeTag="", student_id="")

    code = codeTag
    code = "#{hash[email][:code]}#{codeTag}" if hash.key?(email)

    hash[email] = {
      email: email,
      email_encrypted: email, #"ed", #Student.email_encrypt(email)
      student_id: student_id,
      code: code
    }
    hash
  end

  def author_email
    if self.author.nil? or self.author.email.blank?
      return nil
    else
      return self.author.email
    end
  end

  def admins_emails
    if self.school.nil? or self.school.admins.with_send_email_to_admin.blank?
      return nil
    else
      return self.school.admins.with_send_email_to_admin.pluck(:email)
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

  def pq_create_transaction(amount_in_cents, description="", access_token="", callbackUrl=Rails.application.secrets.payconiq_callback_url, currency='EUR')

    url = URI.parse(Rails.application.secrets.payconiq_host)
    headers = {
      'Content-Type': 'application/json',
      'authorization': access_token,
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


  def get_students_names_by_email(email)

    # for a given email, find student's names targeted for that message
    students_by_email = Student.by_emails(email) # gets all students for a given email

    # then keep only students targeted by the message based on message.groups ans message.students
    students_names = students_by_email.collect do |student|
      gic = false
      gic = group_in_common?(student.groups, self.groups) if (self.groups.present?)

      s_contained_in_m = false
      s_contained_in_m = self.students.include?(student.id) if (self.students.present?)

      student.fullname if (gic or s_contained_in_m)
    end
  end

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
