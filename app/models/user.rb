class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :lockable

  belongs_to :school, required: false
  has_many :messages

  scope :active, -> { where(deleted_at: nil) }


  # role used by pundit
  enum role: [:user, :superadmin, :admin]
  after_initialize :set_default_role, :if => :new_record?

  def set_default_role
   self.role ||= :user
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
  end

  def self.remove_schools(user_id, schools_ids)
    schools_ids.each do |school_id|
      User.where(id: user_id).update_all(['schools = array_remove(schools, ?), updated_at = ?', school_id, Time.now.utc])
    end
  end

  def schools_obj
    School.by_ids(self.schools)
  end

end
