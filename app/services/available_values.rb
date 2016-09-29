module AvailableValues

  class AvailableValuesBase

    attr_accessor :available_values

    def initialize(query, agg)
      response = Search::ContractSearch.new(query, agg).request.raw_response
      @available_values = Search::AggregationParser.new(response).parse_response
    end

    def get_name_from_redis(collection)
      store = Redis::HashKey.new(collection)
      @available_values.each do |hash|
         hash[:title] = store.get(hash[:key])
         hash[:id] = hash.delete(:key)
      end
    end

  end

  class AvailableCountries < AvailableValuesBase

    def initialize(query)
      agg = Search::Aggregation.new('procuring_entity.address.country_name')
      super(query, agg)
    end

    def with_name
      get_name_from_redis('countries')
    end

  end

  class AvailableCpvs  < AvailableValuesBase

    def initialize(query)
      agg = Search::Aggregation.new('x_CPV')
      super(query, agg)
    end

    def with_name
      cpvs = get_name_from_redis('cpvs')
      cpvs.each do |cpv|
        cpv[:text] = cpv.delete(:title)
        order = cpv[:id].match('0*$')[0].length + 1
        cpv_root = cpv[:id].to_i / (10 ** order)
        parent_cpv = cpv_root * 10 ** order
        cpv[:parent]  = parent_cpv > 0 ? parent_cpv.to_s : '#'
      end
    end

  end

  class AvailableYears  < AvailableValuesBase

    def initialize(query)
      agg = Search::Aggregation.new("award.date.x_year")
      super(query, agg)
    end

  end
end
