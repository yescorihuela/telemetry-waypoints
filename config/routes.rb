require 'sidekiq/web'
require 'sidekiq-scheduler/web'

Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  mount Sidekiq::Web => '/sidekiq'
  namespace :api do
    namespace :v1 do
      get 'check_api/', to: 'gps#index', as: :gps_index, format: :json
      get 'latest_waypoints', to: 'gps#latest_waypoints', as: :latest_waypoints, format: :json
      post 'gps', to: 'gps#create_waypoint', as: :gps_create_waypoint, format: :json
    end
  end

  get 'show', to: 'maps#index', as: :gps_map, format: :html
end
