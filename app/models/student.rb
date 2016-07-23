require 'csv'
class Student < ApplicationRecord
  include Code

  before_create :set_code, :set_groups
  before_update :update_level_group, if: :level_changed?
  before_update :update_classroom_group, if: :classroom_changed?

  belongs_to :school, required: false

  default_scope { order('lastname ASC, firstname ASC') }

  validates :code, uniqueness: true

  def groups_obj
    Group.by_ids(self.groups)
  end

  scope :by_ids, ->(ids) { where(id: ids) }
  scope :by_group, ->(id) { where("? = ANY(groups)", id) }
  scope :by_groups, ->(ids) { where("groups && ARRAY[?]::integer[]", ids) }
  scope :by_school, ->(school_id) { where(school_id: school_id) }
  scope :by_code, ->(code) { where(code: code) }

  # http://stackoverflow.com/questions/24236871/in-rails-how-to-add-an-element-to-an-array-type-attribute-for-all-records
  # http://www.postgresql.org/docs/current/static/arrays.html
  # http://www.postgresql.org/docs/current/static/functions-array.html
  def self.add_group(student_ids, group_id)
    Student.by_ids(student_ids).update_all(['groups = array_append(groups, ?)', group_id])
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

  class SentMessageByEmailConverter
    def self.convert(value)
      if value.downcase === "oui" then true else false end
    end
  end

  def self.import(file, school_id)
    options = {
      :chunk_size => 100,
      :key_mapping => {
        :prénom => :firstname,
        :nom => :lastname,
        :emails => :emails,
        :envoi_des_messages_via_email => :sent_message_by_email,
        :année => :level,
        :titulaire => :classroom,
        :code => :code
      },
      :value_converters => {
        :sent_message_by_email => SentMessageByEmailConverter
      }
    }

    SmarterCSV.process(file.tempfile.path, options) do |r|
      r.each do |data|
        groups = []

        data['school_id'] = school_id
        update_or_create data
      end
    end
  end

  # def self.import(file, school_id)
  #   CSV.foreach(file.path, headers: true) do |row|
  #
  #     row_hash = row.to_hash
  #     data = {}
  #
  #     unless row_hash.keys.grep(/first.?name|pr(é|e)nom/i).nil?
  #       firstname_col_name = row_hash.keys.grep(/first.?name|pr(é|e)nom/i)[0]
  #       firstname = row.values_at(firstname_col_name)[0].humanize
  #       data['firstname'] = firstname
  #     end
  #
  #     unless row_hash.keys.grep(/last.?name|^nom/i).nil?
  #       lastname_col_name = row_hash.keys.grep(/last.?name|^nom/i)[0]
  #       lastname = row.values_at(lastname_col_name)[0].humanize
  #       data['lastname'] = lastname
  #     end
  #
  #     unless row_hash.keys.grep(/ann(é|e)|level/i).nil?
  #       level_col_name = row_hash.keys.grep(/ann(é|e)|level/i)[0]
  #       level = row.values_at(level_col_name)[0]
  #       data['level'] = level
  #       level_group = Group.find_or_create_by(name: level, school_id: school_id)
  #     end
  #
  #     unless row_hash.keys.grep(/titulaire|tutor/i).nil?
  #       classroom_col_name = row_hash.keys.grep(/titulaire|tutor/i)[0]
  #       classroom = row.values_at(classroom_col_name)[0].humanize
  #       data['classroom'] = classroom
  #       classroom_group = Group.find_or_create_by(name: classroom, school_id: school_id)
  #     end
  #
  #     unless row_hash.keys.grep(/emails/i).nil?
  #       emails_col_name = row_hash.keys.grep(/emails/i)[0]
  #       emails = row.values_at(emails_col_name)[0].humanize unless
  #       data['emails'] = emails
  #     end
  #
  #     unless row_hash.keys.grep(/code/i).nil?
  #       code_col_name = row_hash.keys.grep(/code/i)[0]
  #       code = row.values_at(code_col_name)[0] unless code_col_name.nil?
  #       data['code'] = code unless code.nil?
  #     end
  #     data['school_id'] = school_id
  #     data['groups'] = [classroom_group.id, level_group.id]
  #
  #     update_or_create data
  #   end
  # end

  private

    def self.update_or_create(attributes)
      # find existing student based on code or ()
      logger.info "update_or_create for #{attributes.inspect}"
      student = nil
      if (attributes[:code].nil?)
        student = Student.where(['firstname = ? and lastname = ? and school_id = ?', attributes[:firstname], attributes[:lastname], attributes['school_id']] ).first
      else
        student = Student.where(['code = ?', attributes[:code]]).first
      end

      if student.nil?
        Student.create(attributes)
      else
        student.update_attributes(attributes) # updater les groupes!!
      end
    end

    def set_code
      compute_code('s', "#{self.school_id}#{self.firstname}#{self.lastname}")
    end

    def update_level_group
      unless self.level_was.nil?
        group_was = find_group(self.level_was, self.school_id)
        self.groups.delete(group_was.id) unless group_was.nil? # remove level_was from self.groups
      end
      unless self.level
        group = find_or_create_group(self.level, self.school_id) # find_or_create level's group
        self.groups.push group.id # add found_or_created group to .self_groups
      end
    end

    def update_classroom_group
      unless self.classroom_was.nil?
        group_was = find_group(self.classroom_was, self.school_id)
        self.groups.delete(group_was.id) unless group_was.nil?
      end
      unless self.classroom.nil?
        group = find_or_create_group(self.classroom, self.school_id)
        self.groups.push group.id
      end
    end

    def set_groups
      # if group is already in self.groups don't add it
      # if remove old level and classroom from self.groups add new ones
      unless self.level.nil?
        group = find_or_create_group(self.level, self.school_id)
        self.groups.push group.id
      end
      unless self.classroom.nil?
        group = find_or_create_group(self.classroom, self.school_id)
        self.groups.push group.id
      end
    end

    def find_group(name, school_id)
      Group.find_by(name: name, school_id: school_id)
    end

    def find_or_create_group(name, school_id)
      Group.find_or_create_by(name: name, school_id: school_id)
    end

end
