require 'csv'
class Student < ApplicationRecord
  include Code

  # after_save :set_code, if: "code.blank?"
  # after_update :set_code, if: "code.blank?"
  before_create  :set_groups, :generate_uuid
  before_update :update_level_and_classroom_groups, if: "classroom_changed? or level_changed?"
  after_update :clean_old_level, if: "level_changed?"
  after_update :clean_old_classroom, if: "classroom_changed?"
  after_destroy :clean_groups

  belongs_to :school, required: false
  has_and_belongs_to_many :users


  default_scope { order('classroom ASC, level ASC, lastname ASC, firstname ASC') }

  validates :firstname, presence: true
  validates :lastname, presence: true
  validates :code, uniqueness: true, :on => :update

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

  # def self.add_groups(student_ids, group_ids)
  #   Student.by_ids(student_ids).update_all(['groups = array_cat(groups, ARRAY[?])', group_ids])
  # end

  def self.remove_group(student_ids, group_ids)
    Student.by_ids(student_ids).update_all(['groups = array_remove(groups, ?)', group_ids])
  end

  # def self.remove_groups(student_ids, group_ids)
  #   group_ids.each do |g_id|
  #     Student.by_ids(student_ids).update_all(['groups = array_remove(groups, ?)', g_id])
  #   end
  # end

  def remove_groups(groups_to_remove)
    self.groups = self.groups - groups_to_remove
  end

  def add_groups(groups_to_add)
    self.groups = self.groups + groups_to_add
  end

  def self.to_csv_file
    attributes = ['Prenom', 'Nom', 'Emails', 'Envoi des messages via email', 'Annee', 'Titulaire', 'Code']
    CSV.generate(headers: true, :col_sep => '\t') do |csv|
      csv << attributes

      all.each do |student|
        firstname = (student.firstname == nil or student.firstname.strip == "")? nil : student.firstname
        lastname = (student.lastname == nil or student.lastname.strip == "")? nil : student.lastname
        emails = (student.emails == nil or student.emails.strip == "")? nil : student.emails
        sent = if student.sent_message_by_email then 'oui' else 'non' end
        level = (student.level == nil or student.level.strip == "")? nil : student.level
        classroom = (student.classroom == nil or student.classroom.strip == "")? nil : student.classroom
        code = (student.code == nil or student.code.strip == "")? nil : student.code

        csv << [firstname,
                lastname,
                emails,
                sent,
                level,
                classroom,
                code]
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
    def generate_uuid
      self.uuid = SecureRandom.uuid
    end

    def set_code
      SetCodeForAStudentJob.perform_later(self)
    end

    def get_old_group(old_name)
      old_group_id = nil
      if old_name.present?
        old_group = find_group(old_name, self.school_id)
        old_group_id = old_group.id unless old_group.nil?
      end
      old_group
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
      old_level_group = get_old_group(self.level_was)
      old_level_group_id = old_level_group.id if old_level_group.present?
      old_classroom_group = get_old_group(self.classroom_was)
      old_classroom_group_id = old_classroom_group.id if old_classroom_group.present?

      new_level_group_id = get_new_group(self.level)
      new_classroom_group_id = get_new_group(self.classroom)

      # update student's groups by removing old groups
      # update student's groups by adding new groups
      array_of_groups = [old_level_group_id, old_classroom_group_id].flatten.uniq.compact

      self.remove_groups(array_of_groups) if array_of_groups.present?

      #Student.remove_groups([self.id], array_of_groups) if array_of_groups.present?
      array_of_groups = [new_level_group_id, new_classroom_group_id].flatten.uniq.compact


      self.add_groups(array_of_groups) if array_of_groups.present?
      #Student.add_groups([self.id], array_of_groups) if array_of_groups.present?

    end

    def clean_old_level
      group = Group.where(name: self.level_was, school_id: self.school_id).first
      group.clean_automatic_group unless group.nil?
    end

    def clean_old_classroom
      group = Group.where(name: self.classroom_was, school_id: self.school_id).first
      group.clean_automatic_group unless group.nil?
    end

    def clean_groups
      # delete groups if empty
      if self.groups.present?
        self.groups.each do |g_id|
          group = Group.find(g_id)
          # don't delete all_students and all_writers
          group.clean_automatic_group unless group.nil?
        end
      end
    end

    def set_groups
      # if group is already in self.groups don't add it
      # if remove old level and classroom from self.groups add new ones
      self.groups = [] if self.groups.nil?

      if self.level.present?
        group = find_or_create_group(self.level, self.school_id)
        #Student.add_group(self.id, group.id)
        self.groups.push(group.id)
      end
      if self.classroom.present?
        group = find_or_create_group(self.classroom, self.school_id)
        #Student.add_group(self.id, group.id)
        self.groups.push(group.id)
      end
      self.groups.uniq!

      all_students = Group.find_by(internal_id: 'all_students', school_id: self.school_id)
      self.groups.push(all_students.id) unless all_students.nil?
      #Student.add_group(self.id, all_students.id) unless all_students.nil?
    end

    def find_group(name, school_id)
      Group.find_by(name: name, school_id: school_id)
    end

    def find_or_create_group(name, school_id)
      # find it
      group = Group.where(name: name, school_id: school_id).first
      if group.nil?
        hash = compute_code(school_id, name)
        recordUniqueCount = 0
        begin
          # group not found, needs to be created
          group = Group.new(name: name, school_id: school_id, updatable: false)
          group.code = 'g' + hash[0] + hash[1].last(4 + name.length % 3)
          group.save
        rescue ActiveRecord::RecordNotUnique
          recordUniqueCount = recordUniqueCount + 1
          group.code = 'g' + hash[0] + hash[1].last(4 + recordUniqueCount + name.length % 3)
          retry
        end
      end
      group
    end
end
