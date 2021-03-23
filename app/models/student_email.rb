class StudentEmail < ApplicationRecord
  belongs_to :student, inverse_of: :student_emails, counter_cache: true

  before_validation do
    self.email = self.email.strip unless self.email.blank?
  end
end
