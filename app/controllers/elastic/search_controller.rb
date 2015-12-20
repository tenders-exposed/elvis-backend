class Elastic::ContractsController < ApiController

  def count
    query = create_query
    number = Search::ContractSearch.new(query).count
    render json: search_json_response(count: number), status: 200
  rescue => exception
    render json: exception, status: 422
  end

  def query
    query = create_query
    results = Search::ContractSearch.new(query).search
    render json: search_json_response(results: results), status: 200
  rescue => exception
    render json: exception, status: 422
  end

  def search_params
    params.permit(countries: [], cpvs: [], years: [], entities: [], suppliers:[])
  end

  def create_query
    Search::Query.new(search_params)
  end

end
