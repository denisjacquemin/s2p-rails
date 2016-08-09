class Group < ApplicationRecord
  include Code

  validates :name, presence: true

  belongs_to :school, required: false

  scope :by_ids, ->(ids) { where(id: ids) }
  scope :by_student_id, ->(student_id) { where("? = ANY(students)", student_id) }
  scope :by_school, ->(school_id) { where(school_id: school_id) }
  scope :all_writers_by_schools, ->(school_ids) { where(internal_id: 'all_writers', school_id: school_ids) }
  scope :all_students_by_school, ->(school_id) { where(internal_id: 'all_students', school_id: school_id) }

  default_scope { order('name ASC') }

  def students
    Student.by_group(self.id)
  end

  def writers
    User.active.by_group(self.id)
  end

  before_destroy :clean_students, :clean_messages

  before_create do
    compute_code('g', "#{self.school_id}#{self.name}")
  end

  def clean_automatic_group
    if (self.updatable === false && self.internal_id != 'all_students' && self.internal_id != 'all_writers')

      students = self.students
      self.destroy if students.blank?
    end
  end

  def managed_automaticaly_for_student?(student)
    # a group is managed automaticaly for a student if
    # - his level
    # - his classroom
    # - all_students
    group_level = Group.where(name: student.level, school_id: student.school_id).first
    group_classroom = Group.where(name: student.classroom, school_id: student.school_id).first
    group_all_students = Group.all_students_by_school(student.school_id).first

    if self == group_level or self == group_classroom or self == group_all_students
      true
    else
      false
    end

  end

  private
    def clean_students
      students_to_clean = Student.by_group(self.id)
      Student.remove_group(students_to_clean, self.id)
    end

    def clean_messages
      messages_to_clean = Message.by_group(self.id)
      Message.remove_group(messages_to_clean, self.id)
    end
end
