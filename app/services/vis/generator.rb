class Vis::Generator
  require 'benchmark'
  attr_accessor :query, :nodes, :edges, :options

  def initialize (query, options = {})
    @query = query
    @nodes = []
    @edges = []
    @options = options
  end

  def generate_json
    generate_nodes
    generate_edges
    {nodes: @nodes, edges: @edges}
  end

  def generate_nodes
    if @options[:nodes] == 'count'
      count_actors('procuring_entity')
      count_actors('suppliers')
    end
    @nodes
  end

  def generate_edges
    if @options[:edges] == 'count'
      count_edges
    end
  end

  def count_actors(actor)
    agg = Search::Aggregation.new("#{actor}.x_slug")
    results = Search::AggregationParser.new(@query, agg).get_results[:results]
    results.map!{ |sup| Vis::Node.new(sup[:key], sup[:doc_count], actor.singularize)}
    @nodes.push(*results)
  end

  def count_edges
    suppliers = Search::Aggregation.new('suppliers.x_slug')
    relations = Search::Aggregation.new('procuring_entity.x_slug', suppliers)
    results = Search::AggregationParser.new(@query, relations).get_results[:results]
    results.map! do |entity|
      entity[:results].map! do |supplier|
        Vis::Edge.new(entity[:key], supplier[:key], supplier[:doc_count])
      end
    end
    @edges.push(*results.flatten)
  end

end
