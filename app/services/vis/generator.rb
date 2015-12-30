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
      count_actors('procuring_entity')
      count_actors('suppliers')
    when 'sum'
      awards_value('procuring_entity')
      awards_value('suppliers')
    else
      raise Vis::GenerationError, "The option \"#{@options[:nodes]}\" is not supported for nodes"
    end
  end

  def generate_edges
    case @options[:edges]
    when 'count'
      count_edges
    when 'sum'
      awards_value_edges
    else
      raise Vis::GenerationError, "The option \"#{@options[:edges]}\" is not supported for edges"
    end
  end

  def count_actors(actor)
    count_per_actor = Search::Aggregation.new("#{actor}.x_slug")
    results = get_results(count_per_actor)
    results.map!{ |res| Vis::Node.new(res[:key], res[:doc_count], actor.singularize).as_json}
    @nodes.push(*results)
  end

  def count_edges
    median = Search::Aggregation.new('numberOfTenderers', type: :percentiles)
    suppliers = Search::Aggregation.new('suppliers.x_slug', embedded_agg: median)
    relations = Search::Aggregation.new('procuring_entity.x_slug',embedded_agg: suppliers)
    results = get_results(relations)
    results.map! do |entity|
      entity[:results].map! do |supplier|
        median = supplier[:values][:"50.0"].to_f
        percent = (supplier[:doc_count] * 100.00 ) / entity[:doc_count]
        Vis::Edge.new(entity[:key], supplier[:key], supplier[:doc_count],
          edge_red_flags(median, percent) ).as_json
      end
    end
    @edges.push(*results.flatten)
  end

  def awards_value(actor)
    award_values = Search::Aggregation.new('award.value.x_amountEur', type: :sum)
    values_per_actor = Search::Aggregation.new("#{actor}.x_slug", embedded_agg: award_values)
    results = get_results(values_per_actor)
    results.map!{ |res| Vis::Node.new(res[:key], res[:value], actor.singularize).as_json}
    @nodes.push(*results)
  end

  def awards_value_edges
    award_values = Search::Aggregation.new('award.value.x_amountEur', type: :sum)
    median = Search::Aggregation.new('numberOfTenderers', type: :percentiles, chained_agg: award_values)
    values_per_suppliers = Search::Aggregation.new('suppliers.x_slug', embedded_agg: median)
    relations = Search::Aggregation.new('procuring_entity.x_slug',embedded_agg: values_per_suppliers)
    results = get_results(relations)
    results.map! do |entity|
      entity[:results].map! do |supplier|
        median = supplier[:values][:"50.0"].to_f
        percent = (supplier[:doc_count] * 100.00 ) / entity[:doc_count]
        Vis::Edge.new( entity[:key], supplier[:key], supplier[:value],
          edge_red_flags(median, percent) ).as_json
      end
    end
    @edges.push(*results.flatten)
  end

  def get_results(agg)
    response = Search::ContractSearch.new(@query, agg).request.raw_response
    Search::AggregationParser.new(response).parse_response
  end

  def edge_red_flags(median, percent)
    hash = {}
    hash[:no_tenderers] = median if median == 1
    hash[:percent_contracts] = percent.round(2) if percent > 50
    hash
  end
end
