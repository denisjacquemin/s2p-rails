require 'httparty'

module Pushwoosh
  class Request
    include HTTParty

    BASE_URI = 'https://cp.pushwoosh.com/json/1.3/'
    FORMAT = :json

    def self.make_post!(*args)
      new().make_post!(*args)
    end

    def make_post!(service_url, options)
      validations!(url, options)
      response = self.class.post(BASE_URI + service_url, body: options.to_json).parsed_response
      Response.new(response)
    end

    private

    attr_reader :options, :base_request, :notification_options, :url

    def validations!(url, options)
      fail Pushwoosh::Exceptions::Error, 'Missing application' unless options.fetch(:application)
      fail Pushwoosh::Exceptions::Error, 'Missing auth key' unless options.fetch(:auth)
      fail Pushwoosh::Exceptions::Error, 'URL is empty' if url.nil? || url.empty?
    end

    # def build_request
    #   { request: full_request_with_notifications }
    # end
    #
    # def full_request_with_notifications
    #   base_request[:request].merge(notifications: [notification_options])
    # end
  end
end
