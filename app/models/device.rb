class Device < ApplicationRecord

  # include PushwooshSync

  scope :by_codes, ->(codes) { where("codes && ARRAY[?]::varchar[]", codes) }
  scope :active, -> { where(active: true) }
  scope :android, -> { where("LOWER(platform) = ?", 'android') }
  scope :ios, -> { where("LOWER(platform) = ?", 'ios') }
  
  def disable
    self.update(active: false)
  end

end
