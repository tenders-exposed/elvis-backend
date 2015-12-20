Rails.application.routes.draw do

    namespace :elastic do
      post 'contracts/search', to: 'search#query'
      post 'contracts/count', to: 'search#count'
      # Aggregation of document countries
      get  'contracts/countries', to: 'countries#index'
      # Query cpvs for autocompletion
      post  'cpvs/autocomplete', to: 'cpvs#autocomplete'
    end

    # Things build to help frontend
    namespace :utility do
      # Get the vis js graph representation
      post 'contracts/graph', to: 'visualization#graph'
    end

end
