class Search::Aggregation
  attr_accessor :subject, :name, :agg, :type, :embedded_agg

  def initialize(field, type = "terms",embedded_agg = nil)
    @subject = field
    @embedded_agg = embedded_agg
    @name = field_name(field)
    @type = type
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
        @type=> {
          field: @subject
        }
      }
    }
    normal_aggregation[@name][@type][:size] = 0 if @type == "terms"
    normal_aggregation[@name][:aggs] = @embedded_agg.agg[:aggs] if @embedded_agg
    normal_aggregation
  end

  def nested_field_aggregation
    nested_aggregation = {
      collection_name => {
        nested: {
          path: nested_path(subject)
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

  def nested_path field
    field.gsub(/(.*)\.[^\.]+$/, '\1')
  end

  def field_name field
    field.split(".").join('_').pluralize.to_sym
  end

  def collection_name
    field_name(nested_path(@subject))
  end

end
