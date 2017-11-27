class Account < ApplicationRecord
  belongs_to :school

  def name_and_number
    "#{self.name} #{self.account_number}"
  end
end
