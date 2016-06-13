class School < ApplicationRecord
  include RailsSettings::Extend

  has_many :users
  has_many :students
  has_many :groups
  has_many :messages

  scope :by_ids, ->(ids) { where(id: ids) }
end
