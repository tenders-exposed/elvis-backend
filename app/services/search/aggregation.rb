class Search::Aggregation
  attr_accessor :subject, :name, :agg, :type, :embedded_agg, :chained_agg, :agg_options

  def initialize(field, options={})
    @subject = field
    @embedded_agg = options[:embedded_agg] ? options[:embedded_agg] : nil
    @chained_agg = options[:chained_agg] ? options[:chained_agg].agg : nil
    @type = options[:type] ? options[:type].to_sym : :terms
    general_options = options.except(:type, :chained_agg, :embedded_agg)
    @agg_options = general_options.reverse_merge(default_options)
    @name = field_name(field)
    @agg =  { aggs: {} }
    build_aggregation
  end

  def build_aggregation
    if nested?(@subject)
      @agg[:aggs] = nested_field_aggregation
    else
      @agg[:aggs] = basic_aggregation
    end
  end

  def basic_aggregation
    normal_aggregation = {
      @name=> {
        @type => {
          field: @subject
        }
      }
    }
    normal_aggregation[@name][@type].merge!(@agg_options)
    if @embedded_agg
      same_path = (@embedded_agg.collection_name == collection_name)
      same_path_agg = @embedded_agg.agg[:aggs][@embedded_agg.collection_name][:aggs]
      agg = same_path ? same_path_agg : reverse_nested_aggregation
      if is_metric?(@type)
        normal_aggregation.merge!(agg)
      else
        normal_aggregation[@name][:aggs] = agg
      end
    end
    normal_aggregation.merge!(@chained_agg[:aggs]) if @chained_agg
    normal_aggregation
  end

  def nested_field_aggregation
    nested_agg = {
      collection_name => {
        nested: {
          path: nested_path(subject)
        },
        aggs: basic_aggregation
      }
    }
  end

  def reverse_nested_aggregation
    reverse_nested_agg = {
      reversed_agg_name => {
        reverse_nested: {},
        aggs:  @embedded_agg.agg[:aggs]
      }
    }
  end

  def nested? field
    analized_field = field.split('.')
    return false if analized_field.size == 1
    return true
  end

  def nested_path field
    field.gsub(/(.*)\.[^\.]+$/, '\1')
  end

  def field_name field
    field.split(".").join('_').pluralize.to_sym
  end

  def collection_name
    field_name(nested_path(@subject))
  end

  def reversed_agg_name
    ('back_for_' + @embedded_agg.collection_name.to_s).to_sym
  end

  def default_options
    case @type
    when :terms
      { size: 0 }
    when :percentiles
      { percents: [50] }
    else
      {}
    end
  end

  def is_metric? type
    metric_types = [:avg, :cardinality, :extended_stats, :geo_bounds,
      :geo_cetroid, :value_count, :max, :min, :percentiles, :percentile_ranks,
      :scripted_metric, :stats, :sum, :top_hits]
    metric_types.include?(type.to_sym)
  end
end
