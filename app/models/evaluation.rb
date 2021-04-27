class Evaluation < ApplicationRecord

    validates_presence_of :description, :weight
    validates :weight, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

    belongs_to :period
    belongs_to :competency
    belongs_to :group
    belongs_to :school
    has_many :quotations, dependent: :destroy

end
