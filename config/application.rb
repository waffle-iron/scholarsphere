# frozen_string_literal: true
require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'socket'
require 'sprockets'
require 'resolv'
require 'uri'
require 'webmock' unless Rails.env.production?

WebMock.disable! if Rails.env.development?

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

module ScholarSphere
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    ss_config = YAML.load(File.read(File.join(Rails.root, 'config/scholarsphere.yml')))[Rails.env].with_indifferent_access

    config.ffmpeg_path = ss_config.fetch(:ffmpeg_path, "ffmpeg")
    config.service_instance = ss_config.fetch(:service_instance, Socket.gethostname)
    config.virtual_host = ss_config.fetch(:virtual_host, "https://#{Socket.gethostname}")

    config.scholarsphere_version = "v2.7"
    config.scholarsphere_release_date = "June 15, 2016"
    config.redis_namespace = "scholarsphere"

    # Number of fits array items shown on the Generic File show page
    config.fits_message_length = 5

    config.assets.enabled = true
    config.assets.compress = !Rails.env.development?

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += Dir["#{config.root}/lib/**/*"]
    config.autoload_paths << Rails.root.join('lib')
    config.autoload_paths += %W(#{config.root}/app/models/datastreams)

    config.i18n.enforce_available_locales = true

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # JavaScript files you want as :defaults (application.js is always included).
    # config.action_view.javascript_expansions[:defaults] = %w(jquery rails)

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    config.stats_email = ss_config.fetch(:stats_email, "ScholarSphere Stats <umg-up.its.sas.scholarsphere-email@groups.ucs.psu.edu>")

    config.stats_from_email = 'umg-up.its.sas.scholarsphere-email@groups.ucs.psu.edu'

    config.max_upload_file_size = 20 * 1024 * 1024 * 1024 # 20GB

    # html maintenance response
    config.middleware.use 'Rack::Maintenance',
                          file: Rails.root.join('public', 'maintenance.html')

    # Time (in seconds) to wait before trying any LDAP queries if initial response is unwilling.
    config.ldap_unwilling_sleep = 2

    # allow errors to be raised in callbacks
    config.active_record.raise_in_transactional_callbacks = true

    # Needed for ScholarsphereLockManager, remove this when we've upgraded to Redis 2.6+
    config.statefile = '/tmp/lockmanager-state'

    config.action_mailer.default_options = { from: "umg-up.its.sas.scholarsphere-email@groups.ucs.psu.edu" }
  end
end
