# coding: utf-8
require 'bundler/setup'
require 'apress/amazon_assets'
require 'combustion'

Combustion.initialize! :active_record

require 'rspec/rails'
require 'factory_girl_rails'
require 'paperclip/matchers'

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  config.include Paperclip::Shoulda::Matchers

  config.use_transactional_fixtures = true
  config.backtrace_exclusion_patterns = [/lib\/rspec\/(core|expectations|matchers|mocks)/]
end