class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :lockable

   # role used by pundit
   enum role: [:user, :superadmin, :admin]
   after_initialize :set_default_role, :if => :new_record?

   def set_default_role
     self.role ||= :user
   end

end
