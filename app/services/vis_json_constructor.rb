class VisJsonConstructor
  attr_accessor :query, :options, :result, :pe_agg, :suppliers_agg

  def initialize(query, options = {})
    @query = query
    @options =options
    @query[:search_type] = "count"
    @result = {}
  end

  def initialize_aggs
    p self
    p self.dup
    new_object = self.dup
    new_object.query[:body][:aggs] = procuring_entities_aggregation
  end

  def aggregate_edges
    @query[:body][:aggs] = yield
    # {
    #   procuring_entities:{
    #     nested: { path: "procuring_entity" },
    #     aggs: {
    #       procuring_entity_names: {
    #         terms: {
    #           field: "procuring_entity.x_slug",
    #           size: 0
    #         },
    #         aggs: {
    #           suppliers: {
    #             nested: { path: "suppliers" },
    #             aggs: {
    #               suppliers_names: {
    #                 terms:{
    #                   field: "suppliers.x_slug",
    #                   size: 0
    #                 }
    #               }
    #             }
    #           }
    #         }
    #       }
    #     }
    #   }
    # }

    Document.es.search(@query).raw_response

  end

  def procuring_entities_aggregation
  {
    procuring_entities:{
      nested: { path: "procuring_entity" },
      aggs: {
        procuring_entity_names: {
          terms: {
            field: "procuring_entity.x_slug",
            size: 0
          }
        }
      }
    }
  }
  end

  def suppliers_aggregation
  {
    suppliers: {
      nested: { path: "suppliers" },
      aggs: {
        suppliers_names: {
          terms:{
            field: "suppliers.x_slug",
            size: 0
          }
        }
      }
    }
  }
  end

  def nodes_count
    related_aggregation = procuring_entities_aggregation[:procuring_entities][:aggs][:procuring_entity_names][:aggs] = suppliers_aggregation
    aggregation = Document.es.search(aggregate_counts{suppliers_aggregation}).raw_response
  end

end
