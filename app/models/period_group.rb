class PeriodGroup < ApplicationRecord

    belongs_to :period
    belongs_to :group

    def group_name
        self.group.name
    end
end