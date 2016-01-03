class Search::ActorDetails

  attr_accessor :query, :slug_id, :details

  def initialize query, slug_id, type
    @query = query
    @slug_id = slug_id.to_i
    @type = type
    @details = {
      slug_id: slug_id,
      name: name,
      total_earnings: total_earnings,
      missing_values: missing_values,
      median: median_tenderers,
      contracts: contracts_list
    }
  end

  def total_earnings
    total = Search::Aggregation.new("award.value.x_amountEur", type: :sum)
    response(total).deep_find("value").round(2)
  end

  def missing_values
    missing = Search::Aggregation.new("award.value.x_amountEur", type: :missing)
    response(missing).deep_find('doc_count').round(2)
  end

  def median_tenderers
    median = Search::Aggregation.new('numberOfTenderers', type: :percentiles)
    response(median).deep_find('values')
  end

  def contracts_list
    wanted_fields = [ 'award.title', 'awardCriteria', 'procuring_entity.name',
      'procuring_entity.slug_id', 'award.value.x_amountEur', 'numberOfTenderers',
      'suppliers.name', 'suppliers.slug_id']
    request = Search::ContractSearch.new(@query, nil, *wanted_fields)
    contracts = request.request.raw_response['hits']['hits'].map{|c| c['_source']}
  end

  def response agg
    response = Search::ContractSearch.new(@query, agg).request.raw_response
    response.extend Hashie::Extensions::DeepFind
  end

  def name
    Contract.find_by("#{@type}.slug_id": @slug_id).suppliers.find_by("slug_id": @slug_id).name
  end


  def flatten_hash hash
    hash.each_with_object({}) do |(k, v), h|
      if v.is_a? Hash
        flatten_hash(v).map do |e_k, e_v|
          h["#{k}.#{e_k}".underscore.to_sym] = e_v
        end
      else
        h[k] = v
      end
     end
  end
end
