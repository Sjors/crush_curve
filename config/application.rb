require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module CrushCurve
  START_DATE = Date.new(2020,3,13)
  # Second wave
  REFERENCE_DATE = Date.new(2020,8,5)
  FIRST_PATIENT_DATE = Date.new(2020,2,1)
  WAVE_2_START_DATE = Date.new(2020,7,1)

  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    config.i18n.available_locales = [:en, :nl]
    config.i18n.default_locale = :nl

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end
