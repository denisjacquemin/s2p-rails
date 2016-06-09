class Device < ApplicationRecord

  scope :by_codes, ->(codes) { where("codes && ARRAY[?]::varchar[]", codes) }
  scope :active, -> { where(active: true) }
  scope :android, -> { where(platform: 'Android') }
  scope :ios, -> { where(platform: 'iOS') }

  def disable
    self.update(active: false)
  end

end
