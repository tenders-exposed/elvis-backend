class Api::V1::NetworksController < Api::V1::ApiController

  before_action :authenticate_user!, only: [:create, :show, :index, :update]

  def index
    @networks = current_user.networks.pluck(:_id, :name)
    render json: @networks, status: 200
  end

  def show
    @network = current_user.networks.find(network_params[:id])
    render json: @network, status: 200
  end

  def create
    @network = current_user.networks.build(query: query_params, options: graph_options)
    if @network.save!
      render json: @network, status: 201
    else
      render json: { errors: @network.errors }, status: 422
    end
  end

  def update
    @network = current_user.networks.find(network_params[:id])
    if @network.update!(query: query_params, options: graph_options, graph: graph_elements)
      render json: @network, status: 200
    else
      render json: {errors: @network.errors}, status: 422
    end
    render json: network_params
  end

  def network_params
    params.permit(:id, :name, :nodes, :edges,countries: [], cpvs: [], years: [],
      entities: [], suppliers:[])
  end

  def query_params
    params_query = network_params.slice(:cpvs, :years, :entities, :suppliers, :countries)
    @network.query.merge(params_query) if @network
  end

  def graph_options
    @network.options.merge(network_params.slice(:nodes, :edges)) if @network
  end

  def graph_elements
    query = Search::Query.new(query_params)
    graph_elements = Vis::Generator.new(query, graph_options).generate_graph_elements
  end

end
