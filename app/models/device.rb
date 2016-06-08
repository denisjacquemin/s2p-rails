class Device < ApplicationRecord

  scope :by_codes, ->(codes) { where("codes && ARRAY[?]::varchar[]", codes) }
  scope :active, -> { where(active: true) }

  def disable
    self.update(active: false)
  end

end
