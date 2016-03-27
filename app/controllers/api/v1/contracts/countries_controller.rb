class Api::V1::Contracts::CountriesController < Api::V1::ApiController
  include SearchResponseFormatter
  include AvailableValues

  def index
    available_countries = AvailableValues::AvailableCountries.new(query)
    countries = available_countries.with_name
    render json: search_json_response(count: countries.size, results: countries),
                 status: 200
  rescue => e
    render_error(e.message)
  end

  def country_params
    params.permit(query: [countries: [], cpvs:[], years: [],
      procuring_entities: [], suppliers: []])
  end

  def query
    Search::Query.new(country_params.fetch(:query, {}))
  end

end
