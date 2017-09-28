class Api::V1::Contracts::ProcuringEntitiesController < Api::V1::ApiController
  include SearchResponseFormatter

  def details
    details = get_procuring_entity_details
    render json: search_json_response(count: query.fetch(:procuring_entities, []).size,
     results: details), status: 200
  rescue => e
      render_error(e.message)
  end

  def procuring_entities_params
    params.permit(query: [countries: [], cpvs:[], years: [], procuring_entities: []])
  end

  def query
    procuring_entities_params.fetch(:query, {})
  end

  def get_procuring_entity_details
    details = []
    query.fetch(:procuring_entities, []).each do |x_slug_id|
      procurer_query = query.except(:procuring_entities).merge(procuring_entities: [x_slug_id])
      query_object = Search::Query.new(procurer_query)
      details << Search::ActorDetails.new(query_object, x_slug_id, "procuring_entity").details
    end
    details
  end

end
