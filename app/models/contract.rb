class Contract
  include Mongoid::Document
  include Mongoid::Elasticsearch

  # Associations
  embeds_one  :tender, inverse_of: :contract
  embeds_one  :award, inverse_of: :contract
  embeds_one  :procuring_entity, inverse_of: :contract
  embeds_many :suppliers, inverse_of: :contract

  # Indexes
  index({ "procuring_entity.x_slug": "hashed" }, {name: "procurer_xslug_index" })

  # Fields
  field :contract_id, type: String
  field :additional_identifiers, type: String
  field :award_criteria, type: String
  field :procurement_method, type: String
  field :x_CPV, type: Array
  field :x_NUTS, type: String
  field :x_eu_project, type: String
  field :x_framework, type: String
  field :x_subcontracted, type: Boolean
  field :number_of_tenderers, type: String
  field :x_lot, type: String
  field :x_additional_information, type: String
  field :x_url, type: String
  field :contract_number, type: String


  # Mappings
  elasticsearch!({
    prefix_name: false,
    index_name: 'contracts',
    index_options: {
      settings: {
        index: {
          requests: {
            cache: { enable: true}
          }
        }
      },
      mappings: {
        contract: {
          properties: {
            number_of_tenderers: {
              type: 'integer',
              index: 'not_analyzed'
            },
            contract_id: {
              type: 'string',
              index: 'not_analyzed'
            },
            additional_identifiers: {
              type: 'string',
              index: 'not_analyzed'
            },
            award_criteria:{
              type: 'string',
              index: 'not_analyzed'
            },
            procuring_entity: {
              type: 'nested',
              properties: {
                address: {
                  type: 'nested',
                  properties: {
                    country_name: {
                      type: 'string',
                      index: 'not_analyzed'
                    },
                    locality:{
                      type: 'string',
                      index: 'not_analyzed'
                    }
                  }
                },
                x_slug: {
                  type: 'string',
                  index: 'not_analyzed'
                },
                x_slug_id: {
                  type: 'integer',
                  index: 'not_analyzed'
                },
                name: {
                  type: 'string',
                  index: 'not_analyzed'
                },
                contract_point: {
                  type: 'nested',
                  properties: {
                    name: {type: 'string'}
                  }
                }
              }
            },
            suppliers: {
              type: 'nested',
              properties: {
                name: {
                  type: 'string',
                  index: 'not_analyzed'
                },
                x_slug: {
                  type: 'string',
                  index: 'not_analyzed'
                },
                x_slug_id: {
                  type: 'integer',
                  index: 'not_analyzed'
                },
                x_same_city: {
                  type: 'integer',
                  index: 'not_analyzed'
                },
                address: {
                  type: 'nested',
                  properties: {
                    locality: {
                      type: 'string',
                      index: 'not_analyzed'
                    },
                    country_name: {
                      type: 'string',
                      index: 'not_analyzed'
                    }
                  }
                }
              }
            },
            tender: {
              type: 'nested',
              properties: {
                value: {
                  type: 'nested',
                  properties: {
                    amount: {type: 'double'},
                    x_amount_eur: {type: 'double'},
                    currency: {type: 'string'},
                    x_vat: {type: 'double'},
                    x_vatbool: {type: 'boolean'}
                  }
                }
              }
            },
            award: {
              type: 'nested',
              properties:{
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
                min_value: {
                  type: 'nested',
                  properties: {
                    amount: {type: 'double'},
                    x_amount_eur: {type: 'double'}
                  }
                },
                value: {
                  type: 'nested',
                  properties: {
                    amount: {type: 'double'},
                    x_amount_eur: {type: 'double'},
                    currency: {type: 'string'},
                    x_vat: {type: 'double'},
                    x_vatbool: {type: 'boolean'}
                  }
                },
                x_initial_value: {
                  type: 'nested',
                  properties: {
                    amount: {type: 'double'},
                    currency: {type: 'string'},
                    x_vat: {type: 'double'},
                    x_amount_eur: {type: 'double'},
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
        }
      }
    },
    wrapper: :load
  })

  def as_json(options={})
    result = super({:except => [:additional_identifiers, :contract_id, :x_lot,
      :x_additional_information, :x_url, :contract_number, :x_NUTS] }.merge(options))
    result[:award] = award.as_json
    result[:suppliers] = suppliers.map{|s| s.as_json}
    result[:procuring_entity] = procuring_entity.as_json
    result
  end

end
