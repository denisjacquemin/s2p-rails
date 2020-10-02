class Group < ApplicationRecord
  include Code
  include AlgoliaSearch

  algoliasearch enqueue: true do
    # list of attribute used to build an Algolia record
    attribute :name, :school_id
    # the attributesToIndex` setting defines the attributes you want to search in
    attributesToIndex ['name', 'school_id']
  end


  validates :name, presence: true
  validates_uniqueness_of :name, scope: :school_id
  #validates :code, uniqueness: true, :on => :update

  belongs_to :school, required: false
  has_and_belongs_to_many :users

  has_many :competency_groups
  has_many :competencies, through: :competency_groups

  has_many :period_groups
  has_many :periods, through: :period_groups

  scope :by_ids, ->(ids) { where(id: ids) }
  scope :by_student_id, ->(student_id) { where("? = ANY(students)", student_id) }
  scope :by_school, ->(school_id) { where(school_id: school_id) }
  #scope :all_writers_by_schools, ->(school_ids) { where(internal_id: 'all_writers', school_id: school_ids) }
  scope :all_students_by_school, ->(school_id) { where(internal_id: 'all_students', school_id: school_id) }
  scope :by_code, ->(code) { where(code: code) }
  scope :only_level, -> { where(group_type: 'level') }
  scope :only_classroom, -> { where(group_type: 'classroom') }

  default_scope { order('name ASC') }

  def group_id
    self.id
  end

  def students
    Student.by_group(self.id).default_order
  end

  def writers
    User.active.by_group(self.id)
  end

  def filtered_competencies
    return (Competency.by_school(self.school_id).where('all_groups = ?', true) | self.competencies).sort{|a, b| a.order <=> b.order}
  end

  before_destroy :clean_students, :clean_messages
  

  # before_save do
  #   logger.debug "Group.before_save compute_code"
  #   self.code = compute_code('g', "#{self.school_id}#{self.name}")
  # end

  def clean_automatic_group
    if (self.updatable === false && self.internal_id != 'all_students' && self.internal_id != 'all_writers') #&& self.internal_id != 'all_writers'

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

  # class methods
  def self.find_or_create_group(name, school_id, type='', upload_id)
    group = Group.where('lower(name) = ? and school_id = ?', name.to_s.downcase.strip, school_id).first
    group.update_column(:upload_id, upload_id) if group and upload_id and group&.upload_id != upload_id # for acaweb and ifapme
    group = Group.create(name: name.to_s.strip, school_id: school_id, updatable: false, group_type: type, upload_id: upload_id) if group.nil?
    group
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
