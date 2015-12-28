class Api::V1::NetworksController < Api::V1::ApiController

  before_action :authenticate_user!, only: [:create,:show]

  def index
    networks = current_user.networks.pluck(:_id, :name)
    render json: networks, status: 200
  end

  def show
    network = current_user.networks.find(network_params[:id])
    render json: network, status: 200
  end

  def create
    query_params = network_params.slice(:cpvs, :years, :entities, :suppliers, :countries)
    query = Search::Query.new(query_params)
    graph_options = {nodes: network_params[:nodes], edges: network_params[:edges]}
    graph_elements = Vis::Generator.new(query, graph_options).generate_graph_elements
    network = current_user.networks.build(query: query_params, options: graph_options, graph: graph_elements)
    if network.save!
      render json: network, status: 201
    else
      render json: { errors: network.errors }, status: 422
    end
  end

  def update

  end

  def network_params
    params.permit(:id, :nodes, :edges,countries: [], cpvs: [], years: [], entities: [], suppliers:[])
  end

end
