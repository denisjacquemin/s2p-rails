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

  def self.to_csv
    attributes = %w{firstname lastname email level classroom code}

    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.each do |student|
        csv << attributes.map{ |attr| student.send(attr) }
      end
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
