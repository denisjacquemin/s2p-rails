class Device < ApplicationRecord

  scope :by_codes, ->(codes) { where("codes && ARRAY[?]::varchar[]", codes) }

end
