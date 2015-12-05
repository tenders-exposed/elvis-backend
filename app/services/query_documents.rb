class QueryDocuments
  attr_accessor :query, :filters, :result

  FIELDS = {  'cpvs' => 'x_CPV',
              'years' => 'awards.year',
              'countries' => 'procuring_entity.country',
              'entities' => 'procuring_entity.x_slug',
              'suppliers' => 'suppliers.x_slug'
            }.freeze

  def initialize
    @filters = []
    @query =  { body:{
                  query: {
                    bool: {
                      must: @filters
                    }
                  }
                }
              }

  end

  def search *options
    build_query *options
    Document.es.search(@query).results
  rescue => e
    return e
  end

  def count *options
    build_query *options
    Document.es.search(@query).total
  rescue => e
    return e
  end

  def graph *options
    opts = options.extract_options!
    calc_options= opts.extract!(:nodes, :edges)
    query_options = [opts]
    build_query *query_options
    VisJsonConstructor.new(@query, calc_options).aggregate_counts
  end

  def build_query *options
    params = options.extract_options!.stringify_keys!
    params.each do |field, value|
      if !(FIELDS.include?(field))
        raise SearchError.new(field), " \"#{field}\" is not a supported query criteria"
      end
      @filters << create_filter(FIELDS[field], value)
    end
  end

  def create_filter field, value
    analized_field = field.split('.')
    condition = { terms: {field =>  value, execution: "bool", _cache: true} }
    if analized_field.size == 1
      return condition
    end
    subject = analized_field.first
    filter =  { nested: {
                  path: subject,
                  query: {
                    bool: {
                      must: [ condition ]
                    }
                  }
                }
              }
  end

end

class SearchError < StandardError
  attr_reader :object

  def initialize(object)
    @object = object
  end

end
