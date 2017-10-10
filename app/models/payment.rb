class Payment < ApplicationRecord
  monetize :price_cents

end
