json.array!(@students) do |student|
  json.extract! student, :id, :firstname, :lastname
  json.url student_url(student, format: :json)
end
