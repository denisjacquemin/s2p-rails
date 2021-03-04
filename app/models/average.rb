class Average < ApplicationRecord
    belongs_to :student
    belongs_to :period
    belongs_to :competency
    belongs_to :group
    belongs_to :school
end
