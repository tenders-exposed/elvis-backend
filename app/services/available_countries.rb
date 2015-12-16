class AvailableCountries

  attr_accessor :countries

  def initialize
    query = Search::Query.new()
    agg = Search::Aggregation.new("procuring_entity.address.countryName")
    @countries = Search::AggregationParser.new(query, agg).get_results
  end

  def with_name
    store = Redis::HashKey.new('countries')
    @countries[:results].map{|hash| hash[:name] = store.get(hash[:key])}
    @countries
  end

end
