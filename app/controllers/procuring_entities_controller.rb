class ProcuringEntitiesController < ApplicationController

  def index
    entities = Post.es.search(
      {
        body: {
          query: {
            query_string: {
              query: params[:search]
            }
          }
        }
      },
       wrapper: :load
    )
  end

  def procuring_entity_params

  end
end
