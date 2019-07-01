json.set! :data do
  json.array! @school_years do |school_year|
    json.partial! 'school_years/school_year', school_year: school_year
    json.url  "
              #{link_to 'Show', school_year }
              #{link_to 'Edit', edit_school_year_path(school_year)}
              #{link_to 'Destroy', school_year, method: :delete, data: { confirm: 'Are you sure?' }}
              "
  end
end