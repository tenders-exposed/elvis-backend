class Api::V1::Utility::VisualizationController < Api::V1::ApiController

  def graph
    query = Search::Query.new(graph_params.except(:nodes, :edges))
    results = Vis::Generator.new(query, {nodes: params[:nodes], edges: params[:edges]}).generate_graph_elements
    render json: results
  rescue => e
    render json: e
  end

  def graph_params
    params.permit(:nodes, :edges,countries: [], cpvs: [], years: [], entities: [], suppliers:[])
  end

end
