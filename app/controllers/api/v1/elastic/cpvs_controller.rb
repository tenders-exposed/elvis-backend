class Api::V1::Elastic::CpvsController < Api::V1::ApiController

  def autocomplete
    cpvs = Search::CpvSearch.new().get_suggestions(cpv_params[:code])
    render json: search_json_response(count: cpvs[:total], results: cpvs[:hits]),
      status: 200
  end

  def cpv_params
    params.permit(:code)
  end

end
