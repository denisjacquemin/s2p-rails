class RatingYear < ApplicationRecord
    scope :by_school, ->(school_id) { where(school_id: school_id) }
    scope :ordered, -> { order(order: :asc) }

    has_many :rating_year_groups
    has_many :groups, through: :rating_year_groups
end
