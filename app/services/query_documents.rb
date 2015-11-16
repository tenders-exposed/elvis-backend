class QueryDocuments
  attr_accessor :query, :results, :count, :filters

  def initialize
    @filters = []
    @query = { body: {
                query: {
                  filtered: {
                    query: { match_all: {} },
                    filter: {
                      bool: {  must: @filters }
                    }
                  }
                }
              }
            }
  end


  def search *options
    build_query *options
    @results = Award.es.search(@query).results

  end

  def count *options
    build_query *options
    @count = Award.es.search(@query).total
  end

  def build_query *options
    params = options.extract_options!.stringify_keys!
    params.each { |k,v| @filters << create_filter(k,v) if create_filter(k,v)}
  end

  def create_filter param, value
    hash ={ terms: {"execution": "bool", "_cache": true} }
    case param
    when 'cpvs'
      hash[:terms]['cpvs'] = value
    when 'years'
      hash[:terms]['date.x_year'] = value
    when 'countries'
      hash[:terms]['country'] = value
    else
      return nil
    end
    hash
  end

end
