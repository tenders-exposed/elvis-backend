class Search::Query
  attr_accessor :query, :filters

  FIELDS =  { 'cpvs' => 'x_CPV',
              'years' => 'award.date.x_year',
              'countries' => 'procuring_entity.address.country_name',
              'procuring_entities' => 'procuring_entity.x_slug_id',
              'suppliers' => 'suppliers.x_slug_id'
            }.freeze

  def initialize(*options)
    @filters = []
    if options.size == 0
      @query = { query: {match_all: {}}}
    else
      @query = { query: bool_query(@filters) }
    end
    build_query *options
  end

  def build_query *options
    params = options.extract_options!.stringify_keys!
    params.each do |field, value|
      if field == 'cpvs'
        value.each do |cpv_prefix|
          @filters << create_filter(FIELDS[field], cpv_prefix, 'prefix_query')
        end
      else
        @filters << filter_query = create_filter(FIELDS[field], value)
      end
    end
  end

  def create_filter field, value, query_type='terms_query'
    if !self.respond_to?(query_type.to_sym)
      raise NotImplementedError.new("#{query_type} query is not implemented yet.")
    end
    query = self.method(query_type.to_sym).call(field, value)
    return query unless nested?(field)
    subject = get_nested(field)
    complete_query = nested_query(subject, bool_query(Array.new().push(query)))
    # If the field is deeply nested, place the query in another nested query
    if nested?(subject)
      return nested_query(get_nested(subject), complete_query)
    else
      return complete_query
    end
  end

  def nested_query field, query
    return {
      nested: {
        path: field,
        query: query
      }
    }
  end

  def terms_query field, value
    return { terms: {field =>  value, execution: "bool", _cache: true} }
  end

  def prefix_query field, value
    return { prefix: { field => value, _cache: true } }
  end

  def bool_query filters
    return { bool: { should: filters } }
  end

  def nested? field
    analized_field = field.split('.')
    return false if analized_field.size == 1
    return true
  end

  def get_nested field
    field.gsub(/(.*)\.[^\.]+$/, '\1')
  end

end
