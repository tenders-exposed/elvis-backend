Rails.application.routes.draw do

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  defaults format: :json do

    devise_for :users, path: "api/v1/users", :controllers => {sessions: 'sessions', registrations: 'registrations',
      confirmations: 'confirmations', passwords: 'passwords'}

    namespace :api do
      namespace :v1 do

        resources :users, only: [:show]
        resources :networks, only: [:create, :index, :show, :update, :destroy]
        resources :cpvs, only: [:index]

        namespace :contracts do
          post '/', to: 'contracts#index'
          post 'count', to: 'contracts#count'
          # Suppliers details in the context of a network
          post 'suppliers_details', to: 'suppliers#details'
          # Procuring Entities in the context of a network
          post 'procuring_entities_details', to: 'procuring_entities#details'
          # All countries in the contracts
          post 'countries', to: 'countries#index'
          # All years in the contracts
          post 'years', to: 'years#index'
          # Get all cpvs in the contracts
          post 'cpvs', to: 'cpvs#index'
          get '/:id', to: 'contracts#show'
        end
      end
    end

    get "/ping" => "info#ping"

    get "/404" => "errors#not_found"
    get "/500" => "errors#internal_server_error"
    get "/422" => "errors#unprocessible_entity"
    get "/401" => "errors#unauthorized"
  end

end
