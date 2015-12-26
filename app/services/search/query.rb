class Search::Query
  attr_accessor :query, :filters

  FIELDS =  { 'cpvs' => 'x_CPV',
              'years' => 'award.date.x_year',
              'countries' => 'procuring_entity.address.countryName',
              'entities' => 'procuring_entity.x_slug',
              'suppliers' => 'suppliers.x_slug'
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
      @filters << create_filter(FIELDS[field], value)
    end
  end

  def create_filter field, value
    terms_query = terms_query(field, value)
    return terms_query unless nested?(field)
    subject = get_nested(field)
    query = nested_query(subject, bool_query(Array.new().push(terms_query)))
    # If the field is deeply nested, place the query in another nested query
    if nested?(subject)
      return nested_query(get_nested(subject), query)
    else
      return query
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

  def bool_query filters
    return { bool: { must: filters } }
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
