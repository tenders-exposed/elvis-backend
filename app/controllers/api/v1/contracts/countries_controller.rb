class Api::V1::Contracts::CountriesController < Api::V1::ApiController

  def index
    countries = AvailableCountries.new().with_name
    render json: search_json_response(count: countries.size, results: countries),status: 200
  rescue => e
    render_error(e.message)
  end

end
