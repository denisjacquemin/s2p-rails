class ReportGroupUser < ApplicationRecord
    belongs_to :user
    belongs_to :group

    scope :by_group, ->(group_id) { where("group_id = ?", group_id) }

end