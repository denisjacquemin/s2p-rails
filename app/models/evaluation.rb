class Evaluation < ApplicationRecord

    validates_presence_of :description

    belongs_to :period
    belongs_to :competency
    belongs_to :group
    belongs_to :school
    has_many :quotations, dependent: :destroy

end
