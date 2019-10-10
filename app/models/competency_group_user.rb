class CompetencyGroupUser < ApplicationRecord
    belongs_to :competency_group
    belongs_to :user
end
