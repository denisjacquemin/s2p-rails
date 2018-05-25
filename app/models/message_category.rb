class MessageCategory < ApplicationRecord
  scope :by_school, ->(school_id) { where(school_id: school_id) }
end
