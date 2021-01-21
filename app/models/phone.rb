class Phone < ApplicationRecord
  belongs_to :student, inverse_of: :phones, counter_cache: true
end
