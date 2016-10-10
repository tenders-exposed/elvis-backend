class Api::V1::Contracts::CpvsController < Api::V1::ApiController
  include SearchResponseFormatter
  include AvailableValues

  def index
    available_cpvs = AvailableValues::AvailableCpvs.new(query)
    cpvs = available_cpvs.with_name
    render json: search_json_response(count: cpvs.size, results: cpvs), status: 200
  rescue => e
    render_error(e.message)
  end

  def cpv_params
    params.permit(:code, query: [countries: [], cpvs:[], years: [],
      procuring_entities: [], suppliers: []])
  end

  def query
    Search::Query.new(cpv_params.fetch(:query, {}))
  end

end
