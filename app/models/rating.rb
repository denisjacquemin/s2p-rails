class Rating < ApplicationRecord
    belongs_to :student
    belongs_to :school
    belongs_to :competency

    # belongs_to :period

    scope :by_competency, -> (competency_id) { where(competency_id: competency_id) }
    scope :by_period, -> (period_id) { where(period_id: period_id) }
    
end
