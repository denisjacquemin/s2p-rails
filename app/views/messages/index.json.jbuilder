json.array!(@messages) do |message|
  json.extract! message, :id, :title, :content, :school_id
  json.url message_url(message, format: :json)
end
