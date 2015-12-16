class Document
  include Mongoid::Document
  include Mongoid::Elasticsearch

  # Associations
  embeds_one  :tender, inverse_of: :document
  embeds_one  :award, inverse_of: :document
  embeds_one  :procuring_entity, inverse_of: :document
  embeds_many :suppliers, inverse_of: :document

  # Fields
  field :document_id, type: String
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
    index_name: 'documents',
    index_options: {
      mappings: {
        document: {
          properties: {
            document_id: {
              type: "string",
              index: "not_analyzed"
            },
            additionalIdentifiers: {
              type: "string",
              index: "not_analyzed"
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
                }
              }
            },
            tender: {
              type: 'nested',
              properties: {
                value: {
                  type: 'nested',
                  properties: {
                    amount: {type: 'float'},
                    x_amountEur: {type: 'float'},
                    currency: {type: 'string'},
                    x_vat: {type: 'float'},
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
                    amount: {type: 'float'},
                    currency: {type: 'string'},
                    x_vat: {type: 'float'}
                  }
                },
                minValue: {
                  type: 'nested',
                  properties: {
                    amount: {type: 'float'},
                    x_amountEur: {type: 'float'}
                  }
                },
                value: {
                  type: 'nested',
                  properties: {
                    amount: {type: 'float'},
                    x_amountEur: {type: 'float'},
                    currency: {type: 'string'},
                    x_vat: {type: 'float'},
                    x_vatbool: {type: 'boolean'}
                  }
                },
                x_initialValue: {
                  type: 'nested',
                  properties: {
                    x_amountEur: {type: 'float'},
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

end
