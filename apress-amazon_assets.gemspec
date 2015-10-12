# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'apress/amazon_assets/version'

Gem::Specification.new do |spec|
  spec.name          = "apress-amazon_assets"
  spec.version       = Apress::AmazonAssets::VERSION
  spec.authors       = ["merkushin"]
  spec.email         = ["merkushin.m.s@gmail.com"]
  spec.summary       = %q{amazon assets}
  spec.description   = %q{amazon assets}
  spec.homepage      = 'https://github.com/abak-press/apress-amazon_assets'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.metadata['allowed_push_host'] = 'https://gems.railsc.ru'

  spec.add_runtime_dependency 'rails', '>= 3.1.12', '< 5.0'
  spec.add_runtime_dependency 'pg'
  spec.add_runtime_dependency 'paperclip', '>= 4.2'
  spec.add_runtime_dependency 'resque-integration'
  spec.add_runtime_dependency 'stringex'
  spec.add_runtime_dependency 'aws-sdk', '>= 1.6', '< 2.0'

  spec.add_development_dependency 'bundler', '>= 1.6'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3.0.0'
  spec.add_development_dependency 'rspec-rails', '~> 3.0.0'
  spec.add_development_dependency 'rspec-given'
  spec.add_development_dependency 'rspec-collection_matchers'
  spec.add_development_dependency 'factory_girl_rails', '>= 3.1'
  spec.add_development_dependency 'shoulda-matchers', '< 3'
  spec.add_development_dependency 'webmock'
  spec.add_development_dependency 'appraisal', '>= 1.0.2'
  spec.add_development_dependency 'combustion', '>= 0.5.3'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'vcr'
end
