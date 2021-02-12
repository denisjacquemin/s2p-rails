class Quotation < ApplicationRecord

    belongs_to :evaluation
    belongs_to :school
    belongs_to :student

end
