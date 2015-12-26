class Award
  include Mongoid::Document
  include Mongoid::Elasticsearch

  # Associations
  embedded_in :contract, inverse_of: :award
  embeds_one :date, class_name: "AwardDate", inverse_of: :award

  embeds_one :value, as: :valuable, inverse_of: :valuable
  embeds_one :x_initialValue, class_name: "XInitialValue", inverse_of: :award
  embeds_one :minValue, class_name: "MinValue", inverse_of: :award
  embeds_one :initialValue, class_name: "InitialValue", inverse_of: :award

  accepts_nested_attributes_for :initialValue, :minValue, :value, :x_initialValue, :date


  # Fields
  field :award_id, type: String
  # award_id will be transalted into award.id at export
  field :title, type: String
  field :description, type: String


  elasticsearch!({
    prefix_name: false,
    index_name: 'awards',
    index_options: {
      mappings: {
        award: {
          properties: {
            date: {
              type: 'nested',
              properties: {
                x_year: {
                  type: 'integer',
                  index: 'not_analyzed'
                },
                x_month: {type: 'integer'},
                x_day: {type: 'integer'}
              }
            },
            initialValue: {
              type: 'nested',
              properties: {
                amount: {type: 'double'},
                currency: {type: 'string'},
                x_vat: {type: 'double'}
              }
            },
            minValue: {
              type: 'nested',
              properties: {
                amount: {type: 'double'},
                x_amountEur: {type: 'double'}
              }
            },
            value: {
              type: 'nested',
              properties: {
                amount: {type: 'double'},
                x_amountEur: {type: 'double'},
                currency: {type: 'string'},
                x_vat: {type: 'double'},
                x_vatbool: {type: 'boolean'}
              }
            },
            x_initialValue: {
              type: 'nested',
              properties: {
                x_amountEur: {type: 'double'},
                x_vatbool: {type: 'boolean'}
              }
            },
            contract_number: {
              type: 'string',
              index: 'not_analyzed'
            }
          }
        }
      }
    },
    wrapper: :load
  })

  def as_json(options={})
    super({:except => [:minValue, :initialValue,
      :x_initialValue]}.merge(options))
  end

end
