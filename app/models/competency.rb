class Competency < ApplicationRecord
    
    include SoftDeletable

    has_many :competency_groups
    has_many :groups, through: :competency_groups

    has_many :competency_periods
    has_many :periods, through: :competency_periods

    belongs_to :school

    validates :name, presence: true

    scope :by_school, ->(school_id) { where(school_id: school_id) }
    scope :ordered, -> { order(order: :asc) }


    def name_with_indent
        ("-" * (level-1) * 2) + " " + (self.title_only ? name.upcase : name)
    end
end