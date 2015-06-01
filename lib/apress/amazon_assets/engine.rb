# coding: utf-8
require 'rails'

module Apress
  module AmazonAssets
    class Engine < ::Rails::Engine
      initializer :apress_amazon_assets, before: :load_init_rb do |app|
        unless app.root.to_s.match root.to_s
          app.config.paths['db/migrate'].concat config.paths['db/migrate'].expanded
        end

        app.config.autoload_paths += [root.join('lib')]
      end

      initializer :apress_amazon_assets_config, before: :load_config_initializers do |app|
        app.config.amazon_assets = {
          defaults: {
            content_types: %w(image/gif image/jpeg image/png),
            max_size: 10.megabytes
          }
        }
      end

      # Initializer allows to use engine factories
      # from a project which depends on the engine
      initializer :apress_amazon_assets_factories, after: 'factory_girl.set_factory_paths' do
        if defined? FactoryGirl
          FactoryGirl.definition_file_paths.unshift root.join('spec', 'factories')
        end
      end

      rake_tasks do
        load 'apress/amazon_assets/tasks.rake'
      end
    end
  end
end