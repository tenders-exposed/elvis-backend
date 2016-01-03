class Api::V1::Contracts::ProcuringEntitiesController < Api::V1::ApiController

  def details
    details = get_procuring_entity_details
    render json: search_json_response(count: procuring_entities_params[:procuring_entities].size,
     results: details), status: 200
   rescue => e
     render_error(e.message)
  end

  def procuring_entities_params
    params.permit(procuring_entities:[], countries: [], cpvs: [], years: [])
  end

  def get_procuring_entity_details
    details = []
     procuring_entities_params[:procuring_entities].each do |slug_id|
      query = Search::Query.new( procuring_entities_params.except(:procuring_entities),
       procuring_entities: [slug_id] )
      details << Search::ActorDetails.new(query, slug_id, "procuring_entity").details
    end
    details
  end

end
