class Search::ContractSearch
  attr_accessor :request, :result

  def initialize(query, aggregation = nil)
    @request = { body: {}}
    @request[:body] = query.query
    if aggregation
      @request[:search_type] = "count"
      @request[:body].merge!(aggregation.agg)
    end
  end

  def search
    request.results
  rescue => e
    return e
  end

  def count
    request.total
  rescue => e
    return e
  end

  def request
    Contract.es.search(@request)
  end
end
