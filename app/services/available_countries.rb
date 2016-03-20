class AvailableCountries

  attr_accessor :countries

  def initialize
    query = Search::Query.new()
    agg = Search::Aggregation.new("procuring_entity.address.country_name")
    response = Search::ContractSearch.new(query, agg).request.raw_response
    @countries = Search::AggregationParser.new(response).parse_response
  end

  def with_name
    store = Redis::HashKey.new('countries')
    @countries.each{|hash| hash[:name] = store.get(hash[:key])}
  end

end
