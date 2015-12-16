class Elastic::SearchController < ApplicationController

  def count
    query = QueryDocuments.new
    number = query.count(search_params)
    render json: number, status: 200
  rescue => exception
      render json: exception, status: 422
  end

  def query
    query = QueryDocuments.new
    results = query.search(search_params)
    render json: results, status: 200
  rescue => exception
    render json: exception, status: 422
  end

  def search_params
    params.permit(:nodes, :edges, countries: [], cpvs: [], years: [], entities: [], suppliers:[])
  end
end
