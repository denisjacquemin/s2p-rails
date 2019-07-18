class Rating < ApplicationRecord
    belongs_to :student
    belongs_to :school
    belongs_to :competency

    validates_uniqueness_of :student_id, :scope => [:school_id, :competency_id, :period_id]

    # t.string "rating"
    # t.string "comment"
    # t.integer "student_id"
    # t.integer "school_id"
    # t.integer "competency_id"
    # t.integer "period_id"


    # belongs_to :period

    scope :by_competency, -> (competency_id) { where(competency_id: competency_id) }
    scope :by_period, -> (period_id) { where(period_id: period_id) }

    
end
