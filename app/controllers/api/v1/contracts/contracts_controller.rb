class Api::V1::Contracts::ContractsController < Api::V1::ApiController
  include SearchResponseFormatter
  include ContractsCsvExporter

  def index
    results = Search::ContractSearch.new(query).search.to_a
    respond_to do |format|
      format.json { render json: search_json_response(results: json_collection(results),
        count: results.size), status: 200 }
      format.csv  { render_csv }
    end
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
    number = Search::ContractSearch.new(query).count
    render json: search_json_response(count: number), status: 200
  rescue => e
    render_error(e.message)
  end


  def contract_params
    params.permit(:id, query: [countries: [], cpvs:[], years: [],
      procuring_entities: [], suppliers: []]).fetch(:query)
  end

  def query
    Search::Query.new(contract_params)
  end

  def json_collection(results)
    results.map!{|result| result.as_json.except!("tender","x_eu_project",
      "x_framework","x_subcontracted")}
  end

  def file_name
    "contracts_export" + super
  end

end
