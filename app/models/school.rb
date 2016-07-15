class School < ApplicationRecord

  has_many :students
  has_many :groups
  has_many :messages

  scope :by_ids, ->(ids) { where(id: ids) }

  def users
    User.by_school(self.id)
  end
end
