Rails.application.routes.draw do
  scope module: 'apress/amazon_assets' do
    namespace :api, defaults: {format: :json} do
      current_api_routes = lambda do
        resources :assets, only: [:show]
      end

      scope module: :v1, &current_api_routes
      namespace :v1, &current_api_routes
    end
  end
end
