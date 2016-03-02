class Group < ApplicationRecord
  belongs_to :school, required: false

  scope :by_ids, ->(ids) { where(id: ids) }
  scope :by_student_id, ->(student_id) { where("? = ANY(students)", student_id) }
  scope :by_school, ->(school_id) { where(school_id: school_id) }

  def students
    Student.by_group_id(self.id)
  end
end
