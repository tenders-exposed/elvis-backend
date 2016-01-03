class Contract
  include Mongoid::Document
  include Mongoid::Elasticsearch

  # Associations
  embeds_one  :tender, inverse_of: :contract
  embeds_one  :award, inverse_of: :contract
  embeds_one  :procuring_entity, inverse_of: :contract
  embeds_many :suppliers, inverse_of: :contract

  accepts_nested_attributes_for :award, :tender

  # Fields
  field :contract_id, type: String
  field :additionalIdentifiers, type: String
  field :awardCriteria, type: String
  field :procurementMethod, type: String
  field :x_CPV, type: Array
  field :x_NUTS, type: String
  field :x_euProject, type: String
  field :x_framework, type: String
  field :x_subcontracted, type: Boolean
  field :numberOfTenderers, type: String
  field :x_lot, type: String
  field :x_additionalInformation, type: String
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
            numberOfTenderers: {
              type: 'integer',
              index: 'not_analyzed'
            },
            contract_id: {
              type: 'string',
              index: 'not_analyzed'
            },
            additionalIdentifiers: {
              type: 'string',
              index: 'not_analyzed'
            },
            awardCriteria:{
              type: 'string',
              index: 'not_analyzed'
            },
            procuring_entity: {
              type: 'nested',
              properties: {
                address: {
                  type: 'nested',
                  properties: {
                    countryName: {
                      type: 'string',
                      index: 'not_analyzed'
                    },
                    country: { type: 'string'}
                  }
                },
                x_slug: {
                  type: 'string',
                  index: 'not_analyzed'
                },
                slug_id: {
                  type: 'integer',
                  index: 'not_analyzed'
                },
                contractPoint: {
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
                x_slug: {
                  type: 'string',
                  index: 'not_analyzed'
                },
                slug_id: {
                  type: 'integer',
                  index: 'not_analyzed'
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
                    x_amountEur: {type: 'double'},
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
        }
      }
    },
    wrapper: :load
  })

  def as_json(options={})
    result = super({:except => [:additionalIdentifiers, :contract_id, :x_lot,
      :x_additionalInformation, :x_url, :contract_number, :x_NUTS] }.merge(options))
    result[:award] = award.as_json
    result[:suppliers] = suppliers.map{|s| s.as_json}
    result[:procuring_entity] = procuring_entity.as_json
    result
  end

end
