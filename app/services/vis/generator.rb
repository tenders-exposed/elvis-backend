class Vis::Generator
  require 'benchmark'
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
    results.map!{ |res| Vis::Node.new(res[:key], res[:doc_count], actor.singularize)}
    @nodes.push(*results)
  end

  def count_edges
    suppliers = Search::Aggregation.new('suppliers.x_slug')
    relations = Search::Aggregation.new('procuring_entity.x_slug',suppliers)
    results = get_results(relations)
    results.map! do |entity|
      entity[:results].map! do |supplier|
        Vis::Edge.new(entity[:key], supplier[:key], supplier[:doc_count])
      end
    end
    @edges.push(*results.flatten)
  end

  def awards_value(actor)
    award_values = Search::Aggregation.new('award.value.x_amountEur', nil, type: :sum)
    values_per_actor = Search::Aggregation.new("#{actor}.x_slug", award_values)
    results = get_results(values_per_actor)
    results.map!{ |res| Vis::Node.new(res[:key], res[:value], actor.singularize)}
    @nodes.push(*results)
  end

  def awards_value_edges
    award_values = Search::Aggregation.new('award.value.x_amountEur', nil, type: :sum)
    values_per_suppliers = Search::Aggregation.new('suppliers.x_slug',award_values)
    relations = Search::Aggregation.new('procuring_entity.x_slug', values_per_suppliers)
    results = get_results(relations)
    results.map! do |entity|
      entity[:results].map! do |supplier|
        Vis::Edge.new(entity[:key], supplier[:key], supplier[:value])
      end
    end
    @edges.push(*results.flatten)
  end

  def get_results(agg)
    response = Search::ContractSearch.new(@query, agg).request.raw_response
    Search::AggregationParser.new(response).parse_response
  end

end
