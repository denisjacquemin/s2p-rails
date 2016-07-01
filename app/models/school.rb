class School < ApplicationRecord

  has_many :users
  has_many :students
  has_many :groups
  has_many :messages
  has_one :mfile


  scope :by_ids, ->(ids) { where(id: ids) }
end
