# require File.expand_path("/mnt/shared/cab/public", __FILE__)
Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.
  CREATIVE_PATH = File.expand_path("../../../tmp",__FILE__)

  #dps_task_api.rb文件的变量配置--------start
  DSP_TOKEN_YOUKU = 'e4c1a60142d2488aa168eb7e74f19456'
  DSP_ID_YOUKU = 11166
  YOUKU_API_STATUS = 'http://miaozhen.atm.youku.com/dsp/api/status'
  DSP_UPLOAD = 'http://miaozhen.atm.youku.com/dsp/api/upload'

  CLIENT_ID = '367e496b1ea3a717'
  CLIENT_SECRET = 'ffdc8f076ad603c574f9f38a30e38b0d'
  ACCESS_TOKEN = 'c71beb52cab1655cdbb769667cd4a6b4'
  REFRESH_TOKEN = 'e78768419f0c0dd02a9a1b284f51ecc7'
  #dps_task_api.rb文件的变量配置-------end

  #youku_upload.rb文件变量定义 -----start
  ACCESS_TOKEN_URL = "https://openapi.youku.com/v2/oauth2/token"
  UPLOAD_TOKEN_URL = "https://openapi.youku.com/v2/uploads/create.json"
  UPLOAD_COMMIT_URL = "https://openapi.youku.com/v2/uploads/commit.json"
  VERSION_UPDATE_URL = "http://open.youku.com/sdk/version_update"
  REFRESH_FILE = "./Public/refresh.txt"
  #youku_upload.rb文件变量定义 -----end
  SERVER_HOST = "http://dev.dsp.hogic.cn/"

 config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true
end
