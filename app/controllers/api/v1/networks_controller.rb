class Api::V1::NetworksController < Api::V1::ApiController
  include ContractsCsvExporter
  before_action :authenticate_user!, only: [:create, :update, :index]

  def index
    @networks = current_user.networks
    render json: @networks, each_serializer: NetworksSerializer, status: 200
  end

  def show
    @network = Network.find(params[:id])
    respond_to do |format|
      format.json { render json: @network, status: 200 }
      format.csv  { render_csv }
    end
  end

  def create
    @network = current_user.networks.build(query: query_params, options: graph_options )
    graph = graph_elements
    write_graph_file(graph)
    if @network.save!
      render json: @network,  status: 201
    else
      render json: { errors: @network.errors }, status: 422
    end
  end

  def update
    @network = current_user.networks.find(params[:id])
    if @network.update!(name: network_params[:name], description: network_params[:description],
       query: @network.query.merge(query_params), options: @network.options.merge(graph_options))
      write_graph_file(network_params[:graph]) if network_params[:graph]
      write_graph_file(graph_elements) unless query_params.empty? && graph_options.empty?
      render json: @network, status: 200
    else
      render json: {errors: @network.errors}, status: 422
    end
  end

  def network_params
    params.require(:network).permit(:id, :name, :description, options: [:nodes, :edges],
      query: [countries: [], cpvs:[], years: [], procuring_entities: [], suppliers: []],
      graph: [ nodes: [], edges: []] )
  end

  private

  def query_params
    network_params.fetch(:query, {})
  end

  def graph_options
    network_params.fetch(:options, {})
  end

  def query
    Search::Query.new(@network.query.symbolize_keys)
  end

  def graph_elements
    Vis::Generator.new(query,@network.options.symbolize_keys).generate_graph_elements
  end

  # TODO: Move this in a before_create
  def write_graph_file(graph)
    path = "#{Rails.root}/networks/#{@network.id}.bin"
    File.delete(path) if File.exist?(path)
    File.open(path, "wb") do |file|
      file << Marshal::dump(graph)
    end
  end

  def file_name
    "#{@network.name}_#{Time.now.strftime("%v")}"
  end

end
