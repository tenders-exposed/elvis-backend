class Elastic::SearchController < ApiController

  def count
    query = create_query
    number = Search::DocumentSearch.new(query).count
    render json: search_json_response(count: number), status: 200
  rescue => exception
      render json: exception, status: 422
  end

  def query
    query = create_query
    results = Search::DocumentSearch.new(query).search
    render json: search_json_response(results: results), status: 200
  rescue => exception
    render json: exception, status: 422
  end

  def search_params
    params.permit(:nodes, :edges, countries: [], cpvs: [], years: [], entities: [], suppliers:[])
  end

  def create_query
    Search::Query.new(search_params.except(:nodes, :edges))
  end

end
