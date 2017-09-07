class Api::V1::NetworksController < Api::V1::ApiController
  include ContractsCsvExporter
  before_action :authenticate_user!, only: [:create, :update, :index, :destroy]

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
    @network = current_user.networks.build(network_params.except(:graph))
    graph = graph_elements
    write_graph_file(graph, file_path)
    if @network.save!
      render json: @network,  status: 201
    else
      render json: { errors: @network.errors }, status: 422
    end
  end

  def update
    @network = current_user.networks.find(params[:id])
    update_params = network_params
    update_params[:options] = @network.options.clone.merge(network_params.fetch(:options, {}))
    update_params[:query] = @network.query.clone.merge(network_params.fetch(:query, {}))
    if @network.update!(update_params.except(:graph))
      write_graph_file(graph.merge(network_params[:graph]), file_path) if network_params[:graph]
      write_graph_file(graph_elements, file_path) if network_params[:query] || network_params[:options]
      render json: @network, status: 200
    else
      render json: { errors: @network.errors }, status: 422
    end
  end

  def destroy
    @network = current_user.networks.find(params[:id])
    if @network.destroy!
      delete_graph_file(file_path)
      head :no_content
    else
      render json: { errors: @network.errors }, status: 422
    end
  end

  def network_params
    params.require(:network).permit(:id, :name, :description,options: [:nodes, :edges],
      query: [countries: [], cpvs:[], years: [], procuring_entities: [], suppliers: []],
      graph: [
        nodes: [:id, :value, :label, :type, :color, flags: [:median]],
        edges: [:from, :to, :value, flags: [:percent_contracts, :x_same_city]],
        clusters: [:id, :name, :type, node_ids: []]
      ]
    )
  end

  private

  def query
    Search::Query.new(@network.query.symbolize_keys)
  end

  def graph_elements
    Vis::Generator.new(query,@network.options.symbolize_keys).generate_graph_elements
  end

  def graph
    Marshal::load( File.open(file_path, "rb"){|f| f.read} )
  end

  # TODO: Move this in a before_create
  def write_graph_file(graph, file_path)
    delete_graph_file(file_path)
    File.open(file_path, "wb") do |file|
      file << Marshal::dump(graph)
    end
  end

  def delete_graph_file(file_path)
    File.delete(file_path) if File.exist?(file_path)
  end

  def file_path
    "#{Rails.root}/networks/#{@network.id}.bin"
  end

  def file_name
    "#{@network.name}_#{Time.now.strftime("%v")}"
  end

end
