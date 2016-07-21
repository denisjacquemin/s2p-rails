class School < ApplicationRecord

  has_many :students, dependent: :destroy
  has_many :groups, dependent: :destroy
  has_many :messages, dependent: :destroy

  scope :by_ids, ->(ids) { where(id: ids) }

  def users
    User.by_school(self.id)
  end

  before_destroy do
    users = User.by_school(self.id)
    users.each do |u|
      User.remove_schools(u.id, [self.id])
    end
  end
end
