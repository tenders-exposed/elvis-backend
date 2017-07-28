module Indices
  class Contracts < Base

    def initialize
      super
      @mapping = {
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
        }
      }
    end

    def populate_index
      cursor = Contract.asc(:id)
      step_size = 1000
      steps = (cursor.count / step_size) + 1
      last_id = nil
      pb = nil
      p "Started indexing #{self.index_name}"
      steps.times do |step|
         if last_id
           docs = cursor.gt(id: last_id).limit(step_size).to_a
         else
           docs = cursor.limit(step_size).to_a
         end
         last_id = docs.last.try(:id)
         contracts = docs.map do |obj|
           json_object = obj.try(:as_indexed_json).try(:as_json)
           { index: { data: json_object }.merge(_id: obj.id.to_s) }
         end
         index_data = {
           index: self.index_name,
           type: 'contract',
           body: contracts,
         }
         @client.bulk(index_data)
         pb = ProgressBar.create(title: self.index_name.capitalize,
                                  total: steps, format: '%t: %p%% %a |%b>%i| %E') if pb.nil?
         pb.increment
      end
    end

  end
end
