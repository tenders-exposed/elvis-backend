module Indices
  class Autocomplete < Base

    def initialize
      super
      @mapping = {
        prefix_name: false,
        index_name: 'autocomplete',
        index_options: {
          settings: {
            index: {
              analysis: {
                filter: {
                  my_asciifolding_filter: {
                    type: 'asciifolding',
                    preserve_original: true
                  },
                  my_edgeNGram_filter: {
                      type: 'edge_ngram',
                      min_gram: 1,
                      max_gram: 20
                  },
                },
                analyzer: {
                  my_edgeNGram_analyzer: {
                    tokenizer: 'standard',
                    filter: ['lowercase', 'my_asciifolding_filter', 'unique', 'my_edgeNGram_filter']
                  },
                },
              },
            }
          },
          mappings: {
            suppliers: {
              properties: {
                name: {
                  type: 'string',
                  analyzer: 'my_edgeNGram_analyzer'
              },
              x_slug_id: {
                type: 'integer',
                index: 'not_analyzed'
              },
              type: {
                type: 'string',
                index: 'not_analyzed'
              }
            }
          },
          procuring_entity: {
            properties: {
              name: {
                type: 'string',
                analyzer: 'my_edgeNGram_analyzer'
              },
              x_slug_id: {
                type: 'integer',
                index: 'not_analyzed'
              },
            }
          },
        }
        }
      }
    end

    def populate_index
      self.index_mappings.each do |entity_name, properties|
        x_slug_ids = Contract.not_in("#{entity_name}.name": nil)
                             .distinct("#{entity_name}.x_slug_id").sort
        step_size = 1000
        steps = (x_slug_ids.size / step_size) + 1
        last_id = nil
        pb = nil
        p "Started indexing #{self.index_name}"
        steps.times do |step|
           if last_id
              current_ids = x_slug_ids.delete_if{ |el| el <= last_id }.take(step_size)
           else
             current_ids = x_slug_ids.take(step_size)
           end
           last_id = current_ids.last
           entities = current_ids.map do |x_slug_id|
             contract = Contract.where("#{entity_name}.x_slug_id": x_slug_id).first
             entity = contract.method("#{entity_name}").call
             entity = entity.first if entity.is_a?(Array)
             json_entity = entity.try(:as_indexed_json).try(:as_json)
             { index: { data: json_entity }.merge(_id: entity.id.to_s) }
           end
           index_data = {
             index: self.index_name,
             type: entity_name,
             body: entities,
           }
           @client.bulk(index_data)
           pb = ProgressBar.create(title: "#{self.index_name}: #{entity_name.capitalize}",
                                    total: steps, format: '%t: %p%% %a |%b>%i| %E') if pb.nil?
           pb.increment
        end
      end
    end

  end
end
