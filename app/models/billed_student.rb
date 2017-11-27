class BilledStudent < ApplicationRecord
  monetize :amount_to_pay_cents
  belongs_to :student
  belongs_to :message
end
