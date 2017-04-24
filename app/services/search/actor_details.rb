class Search::ActorDetails

  attr_accessor :query, :x_slug_id, :details

  def initialize query, x_slug_id, type
    @query = query
    @x_slug_id = x_slug_id.to_i
    @type = type
    @details = {
      x_slug_id: x_slug_id,
      name: name,
      total_earnings: total_earnings,
      missing_values: missing_values,
      median_tenderers: median_tenderers,
      contracts: contracts_list
    }
  end

  def total_earnings
    total = Search::Aggregation.new("award.value.x_amount_eur", type: :sum)
    response(total).deep_find("value").round(2)
  end

  def missing_values
    missing = Search::Aggregation.new("award.value.x_amount_eur", type: :missing)
    response(missing).deep_find('doc_count').round(2)
  end

  def median_tenderers
    median = Search::Aggregation.new('number_of_tenderers', type: :percentiles)
    median_values = response(median).deep_find('values')
    median_50 = median_values['50.0']
    return median_50 == 'NaN' ? nil : median_50
  end

  def contracts_list
    wanted_fields = ['id', 'award.title', 'award.value.x_amount_eur', 'award.date',
      'award_criteria', 'procuring_entity.name', 'procuring_entity.x_slug_id',
      'number_of_tenderers', 'suppliers.name', 'suppliers.x_slug_id']
    request = Search::ContractSearch.new(@query, nil, *wanted_fields)
    contracts = request.request.raw_response['hits']['hits'].map{|c| c['_source']}
  end

  def response agg
    response = Search::ContractSearch.new(@query, agg).request.raw_response
    response.extend Hashie::Extensions::DeepFind
  end

  def name
    if @type == 'suppliers'
      Contract.find_by("suppliers.x_slug_id": @x_slug_id).suppliers.find_by("x_slug_id": @x_slug_id).name
    else
      Contract.find_by("procuring_entity.x_slug_id": 1).procuring_entity.name
    end
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
