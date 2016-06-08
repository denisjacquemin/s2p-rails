class Device < ApplicationRecord

  scope :by_codes, ->(codes) { where("codes && ARRAY[?]::varchar[]", codes) }

  def disable
    self.update(active: false)
  end

end
