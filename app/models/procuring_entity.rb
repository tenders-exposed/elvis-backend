class ProcuringEntity
  include Mongoid::Document
  include Mongoid::Elasticsearch


  # Associations
  belongs_to :document
  has_one :address, as: :addressable, dependent: :destroy, autosave: true
  embeds_one :contractPoint, class_name: "ContractPoint", inverse_of: :procuring_entity

  accepts_nested_attributes_for :contractPoint

  # Fields
  field :name, type: String
  field :x_slug, type: String
  field :x_type, type: String

  elasticsearch!({
    prefix_name: false,
    index_name: 'procuring_entities',
    wrapper: :load
  })

end
