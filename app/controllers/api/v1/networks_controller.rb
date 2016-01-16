class Api::V1::NetworksController < Api::V1::ApiController

  before_action :authenticate_user!, only: [:create, :index, :update]

  def index
    @networks = current_user.networks.pluck(:_id, :name, :description)
    render json: @networks, status: 200
  end

  def show
    # @network = current_user.networks.find(network_params[:id])
    @network = Network.find(network_params[:id])
    respond_to do |format|
      format.json { render json: network_with_graph, status: 200 }
      format.csv  do
        file_name = "#{@network.name}_#{Time.now.strftime("%v")}.csv"
        CsvExportGenerator.new(query).generate_csv(file_name)
        send_file "#{Rails.root}/tmp/#{file_name}", type: "text/csv", status: 200
      end
    end
  end

  def create
    @network = current_user.networks.build(query: query_params, options: graph_options )
    graph = graph_elements
    write_graph_file(graph)
    if @network.save!
      render json: network_with_graph, status: 201
    else
      render json: { errors: @network.errors }, status: 422
    end
  end

  def update
    @network = current_user.networks.find(network_params[:id])
    if @network.update!(name: network_params[:name], description: network_params[:description],
       query: @network.query.merge(query_params), options: @network.options.merge(graph_options))
      write_graph_file(network_params[:graph]) if network_params[:graph]
      write_graph_file(graph_elements) unless query_params.empty? && graph_options.empty?
      render json: network_with_graph, status: 200
    else
      render json: {errors: @network.errors}, status: 422
    end
  end

  def network_params
    params.permit(:id, :name, :description,:nodes, :edges,countries: [], cpvs: [],
     years: [], procuring_entities: [], suppliers:[]).tap do |whitelisted|
      whitelisted[:graph] = params[:graph] if params[:graph]
    end
  end

  private

  def query_params
    network_params.slice(:cpvs, :years, :procuring_entities, :suppliers, :countries)
  end

  def graph_options
    network_params.slice(:nodes, :edges)
  end

  def query
    Search::Query.new(@network.query.symbolize_keys)
  end

  def graph_elements
    Vis::Generator.new(query,@network.options.symbolize_keys).generate_graph_elements
  end

  def write_graph_file(graph)
    path = "#{Rails.root}/networks/#{@network.id}.bin"
    File.delete(path) if File.exist?(path)
    File.open(path, "wb") do |file|
      file << Marshal::dump(graph)
    end
  end

  def read_graph_file
    path = "#{Rails.root}/networks/#{@network.id}.bin"
    Marshal::load( File.open(path, "rb"){|f| f.read} ).as_json
  end

  def network_with_graph
    @network.attributes.merge({graph: read_graph_file})
  end


end
