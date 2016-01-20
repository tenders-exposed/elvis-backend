class Search::ContractSearch
  attr_accessor :request, :result

  def initialize(query, aggregation = nil, *fields)
    @request = { body: {}}
    @request[:body] = query.query
    @request[:body][:_source] = fields.flatten unless fields.empty?
    if aggregation
      @request[:search_type] = "count"
      @request[:body].merge!(aggregation.agg)
    end
  end

  # This function returns an isntance of Mongoid::Criteria with the ids of all contracts
  # that match the search
  def search(from = 0, size = self.count)
    @request[:from] = from
    @request[:size] = size
    @request[:body][:script_fields]= { "ids": { "script": { file: "get_ids" } } }
    ids = request.raw_response["hits"]["hits"].map{|result| result["_id"]}
    Contract.any_in(id: ids)
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
