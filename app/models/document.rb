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
  field :x_CPV, type: String
  field :x_NUTS, type: String
  field :x_euProject, type: String
  field :x_framework, type: String
  field :x_subcontracted, type: Boolean
  field :numberOfTenderers, type: String
  field :x_lot, type: String
  field :x_additionalInformation, type: String
  field :x_url, type: String


  accepts_nested_attributes_for :awards, :procuring_entity

  elasticsearch!({
    prefix_name: false,
    index_name: 'documents',
    wrapper: :load
  })

end
