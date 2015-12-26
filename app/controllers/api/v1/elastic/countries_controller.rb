class Elastic::CountriesController < ApiController

  def index
    countries = AvailableCountries.new().with_name
    render json: search_json_response(count: countries[:doc_count], results: countries[:results]),
      status: 200
  rescue => e
    render_error(e.message)
  end

end
