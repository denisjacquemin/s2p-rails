require File.expand_path('../boot', __FILE__)

require 'rails/all'

require_relative "../app/middleware/handle_bad_encoding_middleware"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

require "google/cloud/translate"



module School2parents
  class Application < Rails::Application

    config.middleware.use HandleBadEncodingMiddleware
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.i18n.default_locale = :fr
    config.autoload_paths << Rails.root.join('lib')

    config.time_zone = "Brussels"
    require "attachinary/orm/active_record" # 
  end
end
