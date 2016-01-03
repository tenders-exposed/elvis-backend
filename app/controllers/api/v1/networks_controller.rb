class Api::V1::NetworksController < Api::V1::ApiController

  before_action :authenticate_user!, only: [:create, :show, :index, :update]

  def index
    @networks = current_user.networks.pluck(:_id, :name, :description)
    render json: @networks, status: 200
  end

  def show
    @network = current_user.networks.find(network_params[:id])
    render json: network_with_graph, status: 200
  end

  def create
    @network = current_user.networks.build(query: query_params, options: graph_options)
    if @network.save!
      render json: network_with_graph, status: 201
    else
      render json: { errors: @network.errors }, status: 422
    end
  end

  def update
    @network = current_user.networks.find(network_params[:id])
    if @network.update!(name: network_params[:name], description: network_params[:description],
       query: query_params, options: graph_options )
      render json: network_with_graph, status: 200
    else
      render json: {errors: @network.errors}, status: 422
    end
  end

  def network_params
    params.permit(:id, :name, :description, :nodes, :edges,countries: [], cpvs: [],
     years: [], procuring_entities: [], suppliers:[])
  end

  def query_params
    params = network_params.slice(:cpvs, :years, :procuring_entities, :suppliers, :countries)
  end

  def graph_options
    options = network_params.slice(:nodes, :edges)
  end

  def graph_elements
    query = Search::Query.new(@network.query.symbolize_keys)
    Rails.logger.debug("QUERY: #{query.inspect}")
    Rails.logger.debug("OPTIONS: #{@network.options.symbolize_keys}")
    graph_elements = Vis::Generator.new(query, @network.options.symbolize_keys).generate_graph_elements
  end

  def network_with_graph
    @network.attributes.merge({graph: graph_elements})
  end

end
