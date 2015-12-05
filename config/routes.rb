Rails.application.routes.draw do
    resources :awards

    post 'search', to: 'search#create'
    post 'search/count', to: 'search#count'
    post 'search/graph', to: 'search#graph'
end
