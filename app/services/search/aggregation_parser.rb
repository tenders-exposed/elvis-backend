class Search::AggregationParser
  attr_accessor :agg, :response

  def initialize(q, agg)
    @agg = agg
    @response = Search::DocumentSearch.new(q, @agg).request.raw_response['aggregations'].deep_symbolize_keys
  end

  def get_results
    result = parse_response(@response, @agg.collection_name, @agg.name)
    if embedded?
      embedded = result.except(:results)
      embedded[:results] = result[:results].map do |res|
        parse_response(res, @agg.embedded_agg.collection_name, @agg.embedded_agg.name)
      end
      embedded
    else
      result
    end
  end

  def embedded?
    return true if @agg.embedded_agg
    return false
  end

  def parse_response(response,collection_name,name)
    result = response.slice(collection_name, :key )
    result[:doc_count] = result[collection_name][:doc_count]
    result[:results] = result.delete(collection_name)[name][:buckets]
    result
  end


end
