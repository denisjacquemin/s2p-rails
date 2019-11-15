class RatingComment < ApplicationRecord
    scope :by_school, ->(school_id) { where(school_id: school_id) }
    scope :ordered, -> { order(order: :asc) }

    has_many :r
    has_many :groups, through: :competency_groups
end
