class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :lockable

  belongs_to :school, required: false
  has_many :messages

  # role used by pundit
  enum role: [:user, :superadmin, :admin]
  after_initialize :set_default_role, :if => :new_record?

  def set_default_role
   self.role ||= :user
  end

  def invitation_status
    if self.invitation_accepted_at.present?
      "accepted"
    else
      "pending"
    end
  end

end
