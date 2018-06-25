module Apress
  module AmazonAssets
    class Engine < ::Rails::Engine
      config.autoload_paths += Dir["#{config.root}/lib"]
      config.autoload_paths += Dir["#{config.root}/app/models/concerns"]
      config.paths.add 'app/docs', eager_load: false

      Apress::Documentation.add_load_path(config.root.join('app/docs'))

      initializer :apress_amazon_assets, before: :load_init_rb do |app|
        unless app.root.to_s.match root.to_s
          app.config.paths['db/migrate'].concat config.paths['db/migrate'].expanded
        end
      end

      initializer :apress_amazon_assets_config, before: :load_config_initializers do |app|
        app.config.amazon_assets = {
          defaults: {
            content_types: %w(image/gif image/jpeg image/png),
            max_size: 10.megabytes
          },
          bucket: "#{APP_NAME}#{"_#{Rails.env}" unless Rails.env.production?}".freeze
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
