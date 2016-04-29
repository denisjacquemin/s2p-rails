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

end
