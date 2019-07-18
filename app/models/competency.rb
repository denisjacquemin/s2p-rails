class Competency < ApplicationRecord
    
    has_many :competency_groups
    has_many :groups, through: :competency_groups

    validates :name, presence: true

    scope :by_school, ->(school_id) { where(school_id: school_id) }
    scope :ordered, -> { order(order: :asc) }

end