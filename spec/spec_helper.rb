# coding: utf-8
require 'bundler/setup'

require 'simplecov'
SimpleCov.start 'rails' do
  minimum_coverage 95
end

require 'apress/amazon_assets'

require 'combustion'
Combustion.initialize! :active_record

require 'rspec/rails'
require 'rspec/given'
require 'rspec/collection_matchers'

require 'factory_girl_rails'
require 'paperclip/matchers'
require 'shoulda-matchers'
require 'webmock/rspec'

require 'test_after_commit'
require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/cassettes'
  config.hook_into :webmock

  config.ignore_request do |request|
    request.method == :head
  end
end

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  config.include Paperclip::Shoulda::Matchers

  config.infer_spec_type_from_file_location!

  config.fixture_path = Rails.root.join('spec', 'fixtures')
  config.use_transactional_fixtures = true

  config.backtrace_exclusion_patterns = [/lib\/rspec\/(core|expectations|matchers|mocks)/]
end