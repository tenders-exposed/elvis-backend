class Vis::Generator
  attr_accessor :query, :nodes, :edges, :options

  def initialize (query, options = {})
    @query = query
    @nodes = []
    @edges = []
    @options = options
  end

  def generate_graph_elements
    generate_nodes
    generate_edges
    {nodes: @nodes, edges: @edges}
  rescue => e
    raise e
  end

  def generate_nodes
    case @options[:nodes]
    when 'count'
      compute_suppliers(:doc_count)
      compute_procurers(:doc_count)
    when 'sum'
      compute_suppliers(:value, award_values_agg)
      compute_procurers(:value, award_values_agg)
    else
      raise Vis::GenerationError, "The option \"#{@options[:nodes]}\" is
       not supported for nodes"
    end
  end

  def generate_edges
    case @options[:edges]
    when 'count'
      compute_edges(:doc_count)
    when 'sum'
      compute_edges(:value, award_values_agg)
    else
      raise Vis::GenerationError, "The option \"#{@options[:edges]}\" is
       not supported for edges"
    end
  end

  def compute_suppliers(field, chained = nil)
    chained_agg = chained ? {chained_agg: chained} : {}
    median = Search::Aggregation.new('numberOfTenderers',
     {type: :percentiles}.merge(chained_agg))
    values_supplier = Search::Aggregation.new('suppliers.slug_id',
     embedded_agg: median)
    results = get_results(values_supplier)
    names = get_names("suppliers")
    results.each_with_index do |a, i|
      a.merge!(names[i])
    end
    results.map! do |res|
      median = res[:values][:"50.0"].to_f
      Vis::Node.new(res[:key], res[:name], res[field.to_sym].round(2),
       'supplier', node_red_flags(median))
    end
    @nodes.push(*results)
  end

  def compute_procurers(field, embedded = nil)
    values_entity = Search::Aggregation.new("procuring_entity.slug_id",
     (embedded ? {embedded_agg: embedded} : {}))
    results = get_results(values_entity)
    names = get_names("procuring_entity")
    results.each_with_index do |a, i|
      a.merge!(names[i])
    end
    results.map!{ |res| Vis::Node.new(res[:key], res[:name],
     res[field.to_sym], 'procuring_entity') }
    @nodes.push(*results)
  end

  def compute_edges(field, embedded = nil)
    same_city_opts = {type: :percentiles, percents: [95]}.merge(
     (embedded ? { embedded_agg: embedded } : {}))
    same_city = Search::Aggregation.new('suppliers.same_city', same_city_opts)
    val_per_suppliers = Search::Aggregation.new('suppliers.slug_id',
     embedded_agg: same_city)
    relations = Search::Aggregation.new('procuring_entity.slug_id',
     embedded_agg: val_per_suppliers)
    results = get_results(relations)
    results.map! do |entity|
      entity[:results].map! do |supplier|
        percent = (supplier[:doc_count] * 100.00 ) / entity[:doc_count]
        same_city = supplier[:values][:"95.0"]
        Vis::Edge.new(entity[:key], supplier[:key], supplier[field.to_sym],
         edge_red_flags(percent, same_city))
      end
    end
    @edges.push(*results.flatten)
  end

  def award_values_agg
    Search::Aggregation.new('award.value.x_amountEur', type: :sum)
  end

  def get_results(agg)
    response = Search::ContractSearch.new(@query, agg).request.raw_response
    Search::AggregationParser.new(response).parse_response
  end

  def edge_red_flags(percent, same_city)
    hash = {}
    hash[:percent_contracts] = percent.round(2) if percent > 50
    hash[:same_city] = same_city if same_city == 1
    hash
  end

  def get_names(actor)
    names = Search::Aggregation.new("#{actor}.name")
    names_by_ids = Search::Aggregation.new("#{actor}.slug_id", embedded_agg: names)
    results = get_results(names_by_ids)
    results.each{|actor| actor[:name] = actor.delete(:results).first[:key]}
  end

  def node_red_flags(median)
    hash = {}
    hash[:median] = median if median == 1
    hash
  end

end
