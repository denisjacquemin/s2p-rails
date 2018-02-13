class Payment < ApplicationRecord
  monetize :price_cents_cents
  scope :succeeded, ->  { where(pq_status: 'SUCCEEDED') }

end
