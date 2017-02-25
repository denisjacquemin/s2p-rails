class Form < ApplicationRecord

  scope :by_muuid, ->(muuid) { where(muuid: muuid) }
  scope :latest_first, -> { order(created_at: :desc) }

end
