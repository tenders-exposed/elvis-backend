Rails.application.routes.draw do

  defaults format: :json do

    devise_for :users, path: "api/v1/users", :controllers => {sessions: 'sessions', registrations: 'registrations',
      confirmations: 'confirmations', passwords: 'passwords'}

    namespace :api do
      namespace :v1 do

        resources :users, only: [:show]
        resources :networks, only: [:create, :index, :show, :update]

        namespace :contracts do
          post '/', to: 'contracts#index'
          post 'count', to: 'contracts#count'
          # Suppliers details in the context of a network
          get 'suppliers_details', to: 'suppliers#details'
          # Procuring Entities in the context of a network
          post 'procuring_entities_details', to: 'procuring_entities#details'
          # All countries in the contracts
          get 'countries', to: 'countries#index'
          # Query cpvs for autocompletion
          get 'cpvs/autocomplete', to: 'cpvs#autocomplete'
          get '/:id', to: 'contracts#show'
        end


      end
    end

    get "/404" => "errors#not_found"
    get "/500" => "errors#internal_server_error"
    get "/422" => "errors#unprocessible_entity"
    get "/401" => "errors#unauthorized"
  end

end
