require 'csv'
class Student < ApplicationRecord
  include Code

  before_create :set_code, if: "code.blank?"
  before_update :set_code, if: "code.blank?"
  after_create  :set_groups
  before_update :update_level_and_classroom_groups, if: "classroom_changed? or level_changed?"

  belongs_to :school, required: false

  default_scope { order('lastname ASC, firstname ASC') }

  validates :firstname, presence: true
  validates :lastname, presence: true
  validates :code, uniqueness: true, if: "code_changed?"

  def groups_obj
    Group.by_ids(self.groups)
  end

  def fullname
    "#{self.lastname} #{self.firstname}"
  end

  scope :by_ids, ->(ids) { where(id: ids) }
  scope :by_group, ->(id) { where("? = ANY(groups)", id) }
  scope :by_groups, ->(ids) { where("groups && ARRAY[?]::integer[]", ids) }
  scope :by_school, ->(school_id) { where(school_id: school_id) }
  scope :by_code, ->(code) { where(code: code) }
  scope :without_group, ->(id) { where.not("? = ANY(groups)", id) }

  # http://stackoverflow.com/questions/24236871/in-rails-how-to-add-an-element-to-an-array-type-attribute-for-all-records
  # http://www.postgresql.org/docs/current/static/arrays.html
  # http://www.postgresql.org/docs/current/static/functions-array.html
  #http://blog.arkency.com/2014/10/how-to-start-using-arrays-in-rails-with-postgresql/
  def self.add_group(student_ids, group_id)
    Student.by_ids(student_ids).without_group(group_id).update_all(['groups = array_append(groups, ?)', group_id])
    #uniq(sort('{1,2,3,2,1}'::int[]))
  end

  def self.add_groups(student_ids, group_ids)
    Student.by_ids(student_ids).update_all(['groups = array_cat(groups, ARRAY[?])', group_ids])
  end

  def self.remove_group(student_ids, group_ids)
    Student.by_ids(student_ids).update_all(['groups = array_remove(groups, ?)', group_ids])
  end

  def self.remove_groups(student_ids, group_ids)
    group_ids.each do |g_id|
      Student.by_ids(student_ids).update_all(['groups = array_remove(groups, ?)', g_id])
    end
  end


  def self.to_csv_file
    attributes = ['Prénom', 'Nom', 'Emails', 'Envoi des messages via email', 'Année', 'Titulaire', 'Code']
    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.each do |student|
        sent = if student.sent_message_by_email then 'oui' else 'non' end
        csv << [student.firstname, student.lastname, student.emails, sent, student.level, student.classroom, student.code]
      end
    end
  end

  # def self.update_or_create(attributes)
  #   logger.info "update_or_create for #{attributes.inspect}"
  #   student = nil
  #   if (attributes[:code].nil?)
  #     student = Student.where(['firstname = ? and lastname = ? and school_id = ?', attributes[:firstname], attributes[:lastname], attributes['school_id']] ).first
  #   else
  #     student = Student.where(['code = ?', attributes[:code]]).first
  #   end
  #
  #   if student.nil?
  #     @student = Student.new attributes
  #     if @student.save
  #       logger.info "student #{@student.firstname} #{@student.lastname} successfully created"
  #     else
  #       logger.info "student create fail for #{@student.firstname} #{@student.lastname} #{@student.errors}"
  #     end
  #   else
  #     if policy(@student).update?
  #       if student.update_attributes(attributes)
  #         logger.info "student #{student.firstname} #{student.lastname} updated"
  #       else
  #         logger.info "student update fail for #{student.firstname} #{student.lastname}"
  #       end
  #     else
  #       logger.info "student update fail for, invalid authorization"
  #     end
  #   end
  # end

  private

    def set_code
      compute_code('s', "#{self.school_id}#{self.firstname}#{self.lastname}")
    end

    def get_old_group(old_name)
      old_group_id = nil
      if old_name.present?
        old_group = find_group(old_name, self.school_id)
        old_group_id = old_group.id unless old_group.nil?
      end
      old_group_id
    end

    def get_new_group(new_name)
      new_group_id = nil
      if new_name.present?
        new_group = find_or_create_group(new_name, self.school_id)
        new_group_id = new_group.id unless new_group.nil?
      end
      new_group_id
    end

    def update_level_and_classroom_groups
      # check if level has changed, if yes get the old and the new group_id
      # check if classroom has changed, if yes get the old and the new group_id
      old_level_group_id = get_old_group(self.level_was)
      old_classroom_group_id = get_old_group(self.classroom_was)

      new_level_group_id = get_new_group(self.level)
      new_classroom_group_id = get_new_group(self.classroom)

      # update student's groups by removing old groups
      # update student's groups by adding new groups
      array_of_groups = [old_level_group_id, old_classroom_group_id].flatten.uniq.compact
      Student.remove_groups([self.id], array_of_groups) if array_of_groups.present?
      array_of_groups = [new_level_group_id, new_classroom_group_id].flatten.uniq.compact
      Student.add_groups([self.id], array_of_groups) if array_of_groups.present?
    end

    def set_groups
      # if group is already in self.groups don't add it
      # if remove old level and classroom from self.groups add new ones
      if self.level.present?
        group = find_or_create_group(self.level, self.school_id)
        Student.add_group(self.id, group.id)
      end
      if self.classroom.present?
        group = find_or_create_group(self.classroom, self.school_id)
        Student.add_group(self.id, group.id)
      end

      all_students = Group.find_by(internal_id: 'all_students', school_id: self.school_id)
      Student.add_group(self.id, all_students.id) unless all_students.nil?
    end

    def find_group(name, school_id)
      Group.find_by(name: name, school_id: school_id)
    end

    def find_or_create_group(name, school_id)
      Group.find_or_create_by(name: name, school_id: school_id, updatable: false)
    end

end
