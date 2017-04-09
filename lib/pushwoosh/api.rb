require 'pushwoosh/request'
require 'pushwoosh/response'

module Pushwoosh
  class API

    def initialize(auth_hash = {})
      @auth_hash = auth_hash
    end

    def registerDevice(options)
      validateRegisterDevice!(options)

      @options = options
      @register_device_request = {
        request: {
          application: @auth_hash[:application]
        }.merge(@options)
      }
      byebug
      response = Request.make_post!('registerDevice', @register_device_request)
      byebug
      logger.info "response: #{response.inspect}"
    end

    private

    attr_reader :auth_hash

    def validateRegisterDevice!(options)
      fail Pushwoosh::Exceptions::Error, 'Missing push token' unless options.fetch(:push_token)
      fail Pushwoosh::Exceptions::Error, 'Missing hwid' unless options.fetch(:hwid)
      fail Pushwoosh::Exceptions::Error, 'Missing device_type' unless options.fetch(:device_type)
    end


  end
end
