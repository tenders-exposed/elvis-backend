class Api::V1::Contracts::SuppliersController < ApplicationController

  def details
    details = suppliers_params[:suppliers].each_with_object({}) do |memo, slug_id|
      query = Search::Query.new(suppliers_params.except(:suppliers), suppliers: [slug_id])
      actor_details = ActorDetails.new(query).details
      memo[:slug_id] =  actor_details
      memo
    end
    render json: search_json_response(count: suppliers_params[:suppliers].size,
     results: details), status: 200
   rescue => e
     render_error(e.message)
  end

  def suppliers_params
    params.permit(suppliers:[], countries: [], cpvs: [], years: [])
  end

end
