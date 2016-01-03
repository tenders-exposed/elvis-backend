class Api::V1::Contracts::SuppliersController < Api::V1::ApiController

  def details
    details = get_supplier_details
    render json: search_json_response(count: suppliers_params[:suppliers].size,
     results: details), status: 200
   rescue => e
     render_error(e.message)
  end

  def suppliers_params
    params.permit(suppliers:[], countries: [], cpvs: [], years: [])
  end

  def get_supplier_details
    details = []
     suppliers_params[:suppliers].each do |slug_id|
      query = Search::Query.new(suppliers_params.except(:suppliers), suppliers: [slug_id])
      details << Search::ActorDetails.new(query, slug_id, "suppliers").details
    end
    details
  end

end