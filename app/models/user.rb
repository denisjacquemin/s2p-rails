class User < ApplicationRecord
  include Code
  include DirtyAssociations

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :lockable, :validate_on_invite => true

  belongs_to :school, required: false
  has_many :messages
  has_and_belongs_to_many :groups, {
    after_add: :set_dirty_associations,
    after_remove: :set_dirty_associations,
  }
  has_and_belongs_to_many :students

  has_many :competency_group_users
  has_many :competency_groups, through: :competency_group_users

  validates :firstname, presence: true
  validates :lastname, presence: true
  # validates :email, presence: true
  #validates_uniqueness_of :email
  scope :active_and_invitation_accepted, -> { where(deleted_at: nil).where.not(invitation_accepted_at: nil) }
  scope :with_send_email_to_admin,  -> { where(send_email_to_admin: true) }
  scope :active, -> { where(deleted_at: nil) }
  scope :by_school, ->(id) { where("? = ANY(schools)", id) }
  scope :by_group, ->(id) { where("? = ANY(groups)", id) }
  scope :by_code, ->(code) { where(code: code) }
  scope :admin, -> { where(role: :admin)}
  scope :superdamin, -> { where(role: :superadmin)}
  scope :no_superadmin, -> { where.not(role: :superadmin)}
  scope :wants_email_notification, -> { where(send_notification_by_email: true) }

  before_create do
    user_key = shake_name(self.firstname,self.lastname).join
    hash = compute_code(0, user_key)
    self.code = 'u' + hash[1].last(4 + user_key.length % 4)
  end

  after_save :createAlgoliaApiKey, if: :algolia_key_needs_update?

  # after_invitation_accepted :set_and_save_all_writers

  # role used by pundit
  enum role: [:user, :superadmin, :admin]
  after_initialize :set_default_role, :if => :new_record?

  def set_default_role
   self.role ||= :user
  end

  def groups_by_school(school_id)
    if self.admin? or self.superadmin?
      return Group.by_school(school_id)
    else
      return self.groups.select {|g| g.school_id == school_id}
    end
  end

  def students_by_school(school_id)
    if self.admin? or self.superadmin?
      return Student.default_order.by_school(school_id)
    else
      return self.students.by_school(school_id)
    end
  end

  def reply_to
    if self.email_reply_to.blank?
      return self.email
    else
      return self.email_reply_to
    end
  end

  def active?
    self.deleted_at === nil
  end

  def invitation_status
    if self.invitation_accepted_at.present?
      "Accepté"
    else
      "En attente"
    end
  end

  def fullname
    "#{self.firstname} #{self.lastname}"
  end

  def active_for_authentication?
    super && !deleted_at
  end

  def inactive_message
    !deleted_at ? super : :deleted_account
  end

  def self.add_schools(user_id, school_ids)
    User.where(id: user_id).update_all(['schools = array_cat(schools, ARRAY[?]), updated_at = ?', school_ids, Time.now.utc])
    set_dirty_associations
  end

  def self.remove_schools(user_id, schools_ids)
    schools_ids.each do |school_id|
      User.where(id: user_id).update_all(['schools = array_remove(schools, ?), updated_at = ?', school_id, Time.now.utc])
    end
    set_dirty_associations
  end

  def self.add_group(user_id, group_id)
    User.find(id: user_id).without_group(group_id).update_all(['groups = array_append(groups, ?)', group_id])
    #uniq(sort('{1,2,3,2,1}'::int[]))
  end

  def schools_obj
    School.by_ids(self.schools)
  end

  # def set_and_save_all_writers
  #   set_all_writers
  #   self.save
  # end
  #
  # def set_all_writers
  #   groups = Group.all_writers_by_schools(self.schools).pluck(:id)
  #   self.groups = groups
  # end

  # def set_groups
  #   all_writers = Group.find_by(internal_id: 'all_writers', school_id: self.school_id)
  #   User.add_group(self.id, all_writers.id) unless all_writers.nil?
  # end

  private
    def createAlgoliaApiKey
      logger.info "Create new Algolia Api Key for #{self.firstname} #{self.lastname}"
      @create_algolia_api_key_service = CreateAlgoliaApiKeyService.new(self)
      @create_algolia_api_key_service.generate_key      
    end

    def algolia_key_needs_update?
      # logger.info "algolia_key_needs_update? #{schools_previously_changed?} || #{role_previously_changed?}  || #{id_previously_changed?}"
      # id_previously_changed? to detect a new creation
      true
      # previous_changed? || schools_previously_changed?
    end
end
