class Group < ApplicationRecord
  belongs_to :school


  def students
    Student.by_group_id(self.id)
  end
end
