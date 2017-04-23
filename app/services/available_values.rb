module AvailableValues

  class AvailableValuesBase

    attr_accessor :available_values

    def initialize(query, agg)
      response = Search::ContractSearch.new(query, agg).request.raw_response
      @available_values = Search::AggregationParser.new(response).parse_response
    end

  end

  class AvailableCountries < AvailableValuesBase

    def initialize(query)
      agg = Search::Aggregation.new('procuring_entity.address.country_name')
      super(query, agg)
    end

    def with_name
      store = Redis::HashKey.new('countries')
      @available_values.each do |hash|
         hash[:text] = store.get(hash[:key])
         hash[:id] = hash.delete(:key)
      end
    end

  end

  class AvailableCpvs  < AvailableValuesBase

    def initialize(query)
      agg = Search::Aggregation.new('x_CPV')
      super(query, agg)
    end

    def with_name
      store = Redis::HashKey.new('cpvs', marshal: true)
      @available_values.each do |hash|
        store_cpv = store.get(hash[:key])
        if store_cpv
          hash[:text] = store_cpv['text']
          hash[:number_digits] = store_cpv['number_digits']
        else
          hash[:text] = nil
          hash[:number_digits] = nil
        end
        hash[:id] = hash.delete(:key)
      end
    end

  end

  class AvailableYears  < AvailableValuesBase

    def initialize(query)
      agg = Search::Aggregation.new("award.date.x_year")
      super(query, agg)
    end

    def with_name
      @available_values.each{|year| year[:id] = year.delete(:key)}
    end

  end
end
