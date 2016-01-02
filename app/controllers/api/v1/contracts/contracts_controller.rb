class Api::V1::Contracts::ContractsController < Api::V1::ApiController

  def index
    query = create_query
    results = Search::ContractSearch.new(query).search
    render json: search_json_response(results: json_collection(results),
      count: results.size), status: 200
  rescue => e
    render_error(e.message)
  end

  def show
    contract = Contract.find(params[:id])
    render json: search_json_response(results: Array.new.push(contract), count: 1),
      status: 200
  rescue => e
    render_error(e.message)
  end

  def count
    query = create_query
    number = Search::ContractSearch.new(query).count
    render json: search_json_response(count: number), status: 200
  rescue => e
    render_error(e.message)
  end


  def contract_params
    params.permit(countries: [], cpvs: [], years: [], entities: [], suppliers:[])
  end

  def create_query
    Search::Query.new(contract_params)
  end

  def json_collection(results)
    results.map!{|result| result.as_json.except!("tender","x_euProject",
      "x_framework","x_subcontracted")}
  end

end
