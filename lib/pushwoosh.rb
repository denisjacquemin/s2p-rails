# require "pushwoosh/lib/version"
# require 'pushwoosh/lib/api'
require 'pushwoosh/configurable'
require 'pushwoosh/api'
# require 'httparty'
#
module Pushwoosh
  extend Pushwoosh::Configurable

  class << self

    def registerDevice(options = {})
      API.new(auth_options).registerDevice(options)
    end

  end
end
