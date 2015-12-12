class Search::Aggregation
  attr_accessor :subject, :name, :agg

  def initialize(field, embedded_aggregation = nil)
    @subject = field
    @embedded_agg = embedded_aggregation
    @name = field.split(".").join('_').pluralize.to_sym
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
        terms: {
          field: @subject,
          size: 0
        }
      }
    }
    normal_aggregation[@name][:aggs] = @nested_agg.agg[:aggs] if @nested_agg
    normal_aggregation
  end

  def nested_field_aggregation
    field = get_nested(@subject)
    name = field.pluralize.to_sym
    nested_aggregation = {
      name=> {
        nested: {
          path: field
        },
        aggs: basic_aggregation
      }
    }
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
