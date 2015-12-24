class Search::Aggregation
  attr_accessor :subject, :name, :agg, :type, :embedded_agg

  def initialize(field, embedded_agg = nil, options={})
    @subject = field
    @embedded_agg = embedded_agg
    @name = field_name(field)
    @type = options[:type] ? options[:type].to_sym : :terms
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
    normal_aggregation[@name][@type][:size] = 0 if @type == :terms
    normal_aggregation[@name][:aggs] = reverse_nested_aggregation if @embedded_agg
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
end
