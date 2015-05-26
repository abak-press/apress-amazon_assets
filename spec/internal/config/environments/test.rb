require File.expand_path('../../../config/const', __FILE__)

if Rails::VERSION::STRING >= '4.2'
  Rails.application.config.active_record.raise_in_transactional_callbacks = true
end
