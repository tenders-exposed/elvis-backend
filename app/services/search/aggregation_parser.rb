class Search::AggregationParser
  attr_accessor :response

  def initialize(response)
    @response = response['aggregations'].deep_symbolize_keys
  end

  def parse_response
    @response.extend Hashie::Extensions::DeepFind
    pe = @response.deep_find(:buckets)
    pes = pe.map do |pe|
      pe.extend  Hashie::Extensions::DeepFind
      pe[:results] = pe.deep_find(:buckets)
      pe[:value] = pe.deep_find(:value)
      if pe[:results]
        pe[:results].map! do |child|
          child.extend Hashie::Extensions::DeepFind
          child[:value] = child.deep_find(:value)
          child.slice(:key, :doc_count, :value).compact
        end
        pe.slice(:key, :doc_count, :results)
      else
        pe.slice(:key, :doc_count, :value).compact
      end
    end
  end

end
