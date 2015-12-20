class Utility::VisualizationController < ApiController

  def graph
    query = Search::Query.new(graph_params.except(:nodes, :edges))
    results = Vis::Generator.new(query, {nodes: params[:nodes], edges: params[:edges]}).generate_json
    render json: results
  end

  def graph_params
    params.permit(:nodes, :edges, countries: [], cpvs: [], years: [], entities: [], suppliers:[])
  end

end
