class Api::V1::Contracts::SuppliersController < Api::V1::ApiController
  include SearchResponseFormatter

  def details
    details = get_supplier_details
    render json: search_json_response(count: query[:suppliers].size,
     results: details), status: 200
   rescue => e
     render_error(e.message)
  end

  def suppliers_params
    params.permit(query: [countries: [], cpvs:[], years: [], suppliers: []])
  end

  def query
    suppliers_params.fetch(:query, {})
  end

  def get_supplier_details
    details = []
     query[:suppliers].each do |x_slug_id|
      query = Search::Query.new(query.except(:suppliers), suppliers: [x_slug_id])
      details << Search::ActorDetails.new(query, x_slug_id, "suppliers").details
    end
    details
  end

end
