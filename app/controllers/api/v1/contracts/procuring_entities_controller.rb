class Api::V1::Contracts::ProcuringEntitiesController < Api::V1::ApiController
  include SearchResponseFormatter

  def details
    details = get_procuring_entity_details
    render json: search_json_response(count: query[:procuring_entities].size,
     results: details), status: 200
  rescue => e
      render_error(e.message)
  end

  def procuring_entities_params
    params.permit(search: [countries: [], cpvs:[], years: [], procuring_entities: []])
  end

  def query
    procuring_entities_params.fetch(:search, {})
  end

  def get_procuring_entity_details
    details = []
    query[:procuring_entities].each do |x_slug_id|
      query = Search::Query.new( query.except(:procuring_entities),
       procuring_entities: [x_slug_id] )
      details << Search::ActorDetails.new(query, x_slug_id, "procuring_entity").details
    end
    details
  end

end
