class Api::V1::Contracts::YearsController < Api::V1::ApiController
  include SearchResponseFormatter
  include AvailableValues

  def index
    years = AvailableValues::AvailableYears.new(query).available_values
    render json: search_json_response(count: years.size, results: years),
                 status: 200
  rescue => e
    render_error(e.message)
  end

  def year_params
    params.permit(query: [countries: [], cpvs:[], years: [],
      procuring_entities: [], suppliers: []])
  end

  def query
    Search::Query.new(year_params.fetch(:query, {}))
  end

end
