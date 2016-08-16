class Message < ApplicationRecord
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

  # def notify_ios(devices = [], text)
  #   apn = Houston::Client.production
  #   apn.certificate = File.read("config/" + Rails.application.secrets.apns_cert_filename) # certificate from prerequisites
  #   apn.passphrase = Rails.application.secrets.ios_push_cert_password
  #   devices.each do |device|
  #     logger.info "Sending Push to #{device.registration_id} with alert=#{text}"
  #     notification = Houston::Notification.new(device: device.registration_id)
  #     notification.alert = text
  #     # take a look at the docs about these params
  #     notification.badge = 57
  #     notification.sound = "sosumi.aiff"
  #     # notification.custom_data = data unless data.nil?
  #     apn.push(notification)
  #   end
  # end

end
