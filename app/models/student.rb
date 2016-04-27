class Student < ApplicationRecord
  belongs_to :school, required: false

  def groups_obj
    Group.by_ids(self.groups)
  end

  scope :by_ids, ->(ids) { where(id: ids) }
  scope :by_group_id, ->(group_id) { where("? = ANY(groups)", group_id) }
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

  before_create do
    self.code = compute_code
  end

  def self.to_csv_file
    attributes = %w{Prénom Nom Email Année Classe Code}
    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.each do |student|
        csv << [student.firstname, student.lastname, '', student.level, student.classroom, student.code]
      end
    end
  end

  def self.import(file, school_id)
    CSV.foreach(file.path, headers: true) do |row|

      row_hash = row.to_hash
      firstname_col_name = row_hash.keys.grep(/first.?name|pr(é|e)nom/i)[0]
      lastname_col_name = row_hash.keys.grep(/last.?name|^nom/i)[0]
      level_col_name = row_hash.keys.grep(/ann(é|e)|level/i)[0]
      classroom_col_name = row_hash.keys.grep(/classe|classroom/i)[0]
      code_col_name = row_hash.keys.grep(/code/i)[0]
      data = {}

      firstname = row.values_at(firstname_col_name)[0].humanize
      lastname = row.values_at(lastname_col_name)[0].humanize
      classroom = row.values_at(classroom_col_name)[0].humanize
      level = row.values_at(level_col_name)[0]
      code = row.values_at(code_col_name)[0] unless code_col_name.nil?

      data['firstname'] = firstname
      data['lastname'] = lastname
      data['classroom'] = classroom
      data['level'] = level
      data['code'] = code unless code.nil?

      data['school_id'] = school_id

      update_or_create data
    end
  end

  def self.update_or_create(attributes)
    # find existing student based on code or ()

    student = nil
    if (attributes['code'].nil?)
      student = Student.where(['firstname = ? and lastname = ? and school_id = ?', attributes['firstname'], attributes['lastname'], attributes['school_id']] ).first
    else
      student = Student.where(['code = ?', attributes['code']]).first
    end
    puts student.inspect
    if (student.nil?)
      Student.create(attributes)
    else
      student.update_attributes(attributes)
    end
  end

  private
    def compute_code
      hashids = Hashids.new(Rails.application.secrets.salt_hashids, 6)
      key = "#{self.school_id}#{self.firstname}#{self.lastname}"
      hash = hashids.encode_hex(key.unpack('H*')[0]).slice(0, 6)
      while !Student.by_code(hash).empty? do
        key = key + "a" # add nothing to the key to generate a different code
        hash = hashids.encode_hex(key.unpack('H*')[0]).slice(0, 6)
      end
      return hash
    end

end
