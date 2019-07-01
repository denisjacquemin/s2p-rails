class CompetencyGroup < ApplicationRecord
    belongs_to :competency
    belongs_to :group

    has_many :competency_group_users
    has_many :users, through: :competency_group_users

    def group_name
        self.group.name
    end
end
