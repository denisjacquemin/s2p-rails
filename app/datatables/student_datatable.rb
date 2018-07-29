class StudentDatatable < AjaxDatatablesRails::Base
  extend Forwardable

  def_delegator :@view, :check_box_tag

  def initialize(params, opts = {})
    @view = opts[:view_context]
    super
  end

  def view_columns
    # Declare strings in this format: ModelName.column_name
    # or in aliased_join_table.column_name format
    @view_columns ||= {
      id:         { source: "Student.id",         cond: :eq,    searchable: false },
      lastname:   { source: "Student.lastname",   cond: :like,  searchable: true  },
      firstname:  { source: "Student.firstname",  cond: :like,  searchable: true  },
      level:      { source: "Student.level",      cond: :like,  searchable: true  },
      classroom:  { source: "Student.classroom",  cond: :like,  searchable: true  }
    }
  end

  def data
    records.map do |record|
      {
        id: check_box_tag("cb_#{record.id}", record.id, nil),
        lastname: record.lastname,
        firstname: record.firstname,
        level: record.level,
        classroom: record.classroom
      }
    end
  end

  def current_user
    @current_user ||= options[:current_user]
  end

  def current_school_id
    @current_school_id ||= options[:current_school_id]
  end

  def get_raw_records
    current_user.students_by_school(current_school_id)
  end

end
