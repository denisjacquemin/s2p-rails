class Device < ApplicationRecord

  scope :by_codes, ->(codes) { where("codes && ARRAY[?]::varchar[]", codes) }

  def disable
    self.active = false
    self.save
  end

end
