class Group < ApplicationRecord
  include Code

  belongs_to :school, required: false

  scope :by_ids, ->(ids) { where(id: ids) }
  scope :by_student_id, ->(student_id) { where("? = ANY(students)", student_id) }
  scope :by_school, ->(school_id) { where(school_id: school_id) }

  default_scope { order('name ASC') }

  def students
    Student.by_group(self.id)
  end

  before_destroy :clean_students, :clean_messages

  before_create do
    compute_code('g', "#{self.school_id}#{self.name}")
  end

  private
    def clean_students
      students_to_clean = Student.by_group(self.id)
      Student.remove_group(students_to_clean, self.id)
    end

    def clean_messages
      byebug
      messages_to_clean = Message.by_group(self.id)
      Message.remove_group(messages_to_clean, self.id)
    end
end
