class ProcuringEntity
  include Mongoid::Document
  include Mongoid::Elasticsearch

  # Associations
  embedded_in :contract, inverse_of: :procuring_entity
  embeds_one :address, as: :addressable, inverse_of: :addressable
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

  def as_json(options={})
    super({:except => [:address,:contractPoint]}.merge(options))
  end

end
