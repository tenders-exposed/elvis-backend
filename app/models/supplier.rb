class Supplier
  include Mongoid::Document
  include Mongoid::Elasticsearch

  # Associations
  embedded_in :contract
  embeds_one :address, as: :addressable, inverse_of: :addressable

  # Fields
  field :name, type: String
  field :x_slug, type: String, default: nil
  field :x_slug_id, type: Integer, default: nil
  field :x_same_city, type: Integer, default: nil

  # Mapping
  elasticsearch!({
    prefix_name: false,
    index_name: 'autocomplete',
    index_options: {
      settings: {
        index: {
          analysis: {
            analyzer: {
              my_edgeNGram_analyzer: {
                tokenizer: 'my_edgeNGram_tokenizer',
                filter: ['lowercase', 'my_asciifolding_filter', 'unique']
              }
            },
            tokenizer: {
              my_edgeNGram_tokenizer: {
                type: 'edgeNGram',
                min_gram: 2,
                max_gram: 6,
                token_chars: ['letter', 'digit', 'punctuation']
              }
            },
            filter: {
              my_asciifolding_filter: {
                type: 'asciifolding',
                preserve_original: true
              }
            }
          }
        }
      },
      mappings: {
        supplier: {
          properties: {
            suggest: {
              type: 'completion',
              analyzer: 'my_edgeNGram_analyzer',
              payloads: true,
            },
            name: {
              type: 'string'
            },
            x_slug: {
              type: 'string',
              index: 'not_analyzed'
            },
            x_slug_id: {
              type: 'integer',
              index: 'not_analyzed'
            }
          }
        }
      }
    },
    wrapper: :load
  })

  # customize what gets sent to elasticsearch:
  def as_indexed_json
    name_words = self.name.to_s.gsub(/\s([[:punct:]])\s/, '\1').split(/\s/)
    name_words.append(self.name.to_s)
    name_tokens = name_words.map{|word| word.gsub(/[[:punct:]]/, '')}
    self.attributes.except('_id').merge!({
      'suggest': {
        'input': name_tokens + name_words,
        'output': self.name,
        'payload': {
          'name': self.name,
          'x_slug_id': self.x_slug_id
        }
      }
    })
  end

  def as_json(options={})
    super({:except => [:address]}.merge(options))
  end

end
