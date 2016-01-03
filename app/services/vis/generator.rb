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
    results.map! do |res|
      median = res[:values][:"50.0"].to_f
      Vis::Node.new(res[:key], res[field.to_sym].round(2), 'supplier',
       node_red_flags(median)).as_json
    end
    @nodes.push(*results)
  end

  def compute_procurers(field, embedded = nil)
    values_entity = Search::Aggregation.new("procuring_entity.slug_id",
     (embedded ? {embedded_agg: embedded} : {}))
    results = get_results(values_entity)
    results.map!{ |res| Vis::Node.new(res[:key], res[field.to_sym], 'procuring_entity').as_json}
    @nodes.push(*results)
  end

  def compute_edges(field, embedded = nil)
    values_per_suppliers = Search::Aggregation.new('suppliers.slug_id',
     (embedded ? {embedded_agg: embedded} : {}))
    relations = Search::Aggregation.new('procuring_entity.slug_id',
     embedded_agg: values_per_suppliers)
    results = get_results(relations)
    results.map! do |entity|
      entity[:results].map! do |supplier|
        percent = (supplier[:doc_count] * 100.00 ) / entity[:doc_count]
        Vis::Edge.new(entity[:key], supplier[:key], supplier[field.to_sym],
         edge_red_flags(percent)).as_json
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

  def edge_red_flags(percent)
    hash = {}
    hash[:percent_contracts] = percent.round(2) if percent > 50
    hash
  end

  def node_red_flags(median)
    hash = {}
    hash[:median] = median if median == 1
    hash
  end

end
