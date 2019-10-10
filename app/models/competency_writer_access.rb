class CompetencyWriterAccess < ApplicationRecord
    belongs_to :competency_group
    belongs_to :user
    belongs_to :school
end
