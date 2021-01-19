class Period < ApplicationRecord
    scope :by_school, ->(school_id) { where(school_id: school_id) }
    scope :ordered, -> { order(order: :asc) }
    scope :without_weights, -> {where(is_weight: false)}

    has_many :period_groups
    has_many :groups, through: :period_groups
end
