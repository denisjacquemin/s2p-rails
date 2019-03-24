class Translation < ApplicationRecord
    belongs_to :message
    belongs_to :school
end
