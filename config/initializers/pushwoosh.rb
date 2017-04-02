Pushwoosh.configure do |config|
  config.application = ENV["PUSHWOOSH_APPLICATION_CODE"]
  config.auth = ENV["PUSHWOOSH_API_TOKEN"]
end
