Rails.application.routes.draw do

    resources :awards

    namespace :elastic do
      post 'documents/search', to: 'search#create'
      post 'documents/count', to: 'search#count'
      # Aggregation of document countries
      get  'documents/countries', to: 'countries#index'
      # Query cpvs for autocompletion
      get  'cpvs/autocomplete', to: 'cpvs#autocomplete'
    end

    # Things build to help frontend
    namespace :utility do
      # Get the vis js graph representation
      post 'documents/graph', to: 'visualization#graph'
    end

end
