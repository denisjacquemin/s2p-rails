class RatingComment < ApplicationRecord
    scope :by_school, ->(school_id) { where(school_id: school_id) }
    scope :ordered, -> { order(order: :asc) }
    scope :by_rating_year, -> (rating_year_id) { where(year_id: rating_year_id) }


    belongs_to :student
    belongs_to :school
    belongs_to :period
end
