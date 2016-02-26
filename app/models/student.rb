class Student < ApplicationRecord
  belongs_to :school, required: false
end
