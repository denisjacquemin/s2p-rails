require 'pushwoosh/pushwoosh_sync'
require 'pushwoosh'
Pushwoosh.configure do |config|
  config.application = ENV["PUSHWOOSH_APPLICATION_CODE"]
  config.auth = ENV["PUSHWOOSH_API_TOKEN"]
end
# include Pushwoosh
# Pushwoosh.configure do |config|
#   config.application = ENV["PUSHWOOSH_APPLICATION_CODE"]
#   config.auth = ENV["PUSHWOOSH_API_TOKEN"]
# end
