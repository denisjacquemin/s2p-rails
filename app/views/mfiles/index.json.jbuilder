json.array!(@mfiles) do |mfile|
  json.extract! mfile, :id, :filename, :file_url, :school_id, :message_id
  json.url mfile_url(mfile, format: :json)
end
