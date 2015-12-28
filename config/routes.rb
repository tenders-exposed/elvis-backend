Rails.application.routes.draw do

  defaults format: "json" do
    devise_for :users, :controllers => {sessions: 'sessions', registrations: 'registrations',
      confirmations: 'confirmations', passwords: 'passwords'}

    resources :users, only: [:show]

    namespace :api do
      namespace :v1 do

        resources :networks, only: [:create, :index, :show]

        namespace :elastic do
          get 'contracts', to: 'contracts#index'
          get 'contracts/:id', to: 'contracts#show'
          get 'contracts/count', to: 'contracts#count'
          # Aggregation of document countries
          get 'contracts/countries', to: 'countries#index'
          # Query cpvs for autocompletion
          get 'cpvs/autocomplete', to: 'cpvs#autocomplete'
        end


      end
    end

    get "/404" => "errors#not_found"
    get "/500" => "errors#internal_server_error"
    get "/422" => "errors#unprocessible_entity"
  end

end
