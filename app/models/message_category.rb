class MessageCategory < ApplicationRecord

  has_and_belongs_to_many :students

  scope :by_school, ->(school_id) { where(school_id: school_id) }
end
