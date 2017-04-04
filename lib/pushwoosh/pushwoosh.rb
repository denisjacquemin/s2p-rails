# require "pushwoosh/lib/version"
# require 'pushwoosh/lib/api'
require 'pushwoosh/lib/configurable'
# require 'httparty'
#
module Pushwoosh
  extend Pushwoosh::Configurable

  class << self

    def registerDevice(options = {})
      PushNotification.new(options).registerDevice(options)
    end

  end
end
