class Student < ApplicationRecord
  belongs_to :school, required: false

  scope :by_ids, ->(ids) { where(id: ids) }
  scope :by_group_id, ->(group_id) { where("? = ANY(groups)", group_id) }
  scope :by_school, ->(school_id) { where(school_id: school_id) }

  # http://stackoverflow.com/questions/24236871/in-rails-how-to-add-an-element-to-an-array-type-attribute-for-all-records
  # http://www.postgresql.org/docs/current/static/arrays.html
  # http://www.postgresql.org/docs/current/static/functions-array.html
  def self.add_group(student_ids, group_id)
    Student.by_ids(student_ids).update_all(['groups = array_append(groups, ?)', group_id])
  end

  def self.remove_group(student_ids, group_id)
    Student.by_ids(student_ids).update_all(['groups = array_remove(groups, ?)', group_id])
  end
end
