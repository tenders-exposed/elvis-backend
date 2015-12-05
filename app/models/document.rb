class Document
  include Mongoid::Document
  include Mongoid::Elasticsearch

  # Associations
  has_many :tenders, dependent: :destroy
  has_many :awards, dependent: :destroy
  has_one  :procuring_entity, dependent: :destroy, autosave: true
  has_many :suppliers, dependent: :destroy

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

  # Mappings
  elasticsearch!({
    prefix_name: false,
    index_name: 'documents',
    index_options: {
      mappings: {
        document: {
          properties: {
            procuring_entity: {
              type: 'nested',
              properties: {
                country: {
                  type: 'string',
                  index: 'not_analyzed'
                },
                x_slug: {
                  type: 'string',
                  index: 'not_analyzed'
                }
              }
            },
            awards: {
              type: 'nested',
              properties:{
                year: {
                  type: 'string',
                  index: 'not_analyzed'
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
            }
          }
        }
      }
    },
    wrapper: :load
  })

  # Indexed Data
  def as_indexed_json
    {
      document_id: document_id,
      additionalIdentifiers: additionalIdentifiers,
      awardCriteria: awardCriteria,
      procurementMethod: procurementMethod,
      x_CPV: x_CPV,
      x_NUTS: x_NUTS,
      x_euProject: x_euProject,
      x_framework: x_framework,
      x_subcontracted: x_subcontracted,
      numberOfTenderers: numberOfTenderers,
      x_lot: x_lot,
      x_additionalInformation: x_additionalInformation,
      x_url: x_url,
      suppliers: suppliers,
      procuring_entity: {
        _id: procuring_entity.id,
        country: index_country_name,
        x_slug: procuring_entity.x_slug,
        name: procuring_entity.name
      },
      awards: index_awards
    }
  end

  def index_country_name
    procuring_entity.address ? procuring_entity.address.countryName : nil
  end

  def index_awards
    mapped_awards = Array.new()
    mapped_awards << awards.to_a.inject({}) do |result, award|
      result["_id"]= award.id
      result["year"] = award.date.x_year
      result["value"] = award.value.x_amountEur
      result
    end
    mapped_awards
  end

end
