class ProcuringEntity
  include Mongoid::Document

  # Associations
  embedded_in :contract, inverse_of: :procuring_entity
  embeds_one :address, as: :addressable, inverse_of: :addressable
  embeds_one :contract_point, class_name: "ContractPoint", inverse_of: :procuring_entity

  accepts_nested_attributes_for :contract_point

  # Fields
  field :name, type: String
  field :x_slug, type: String
  field :x_type, type: String
  field :x_slug_id, type: Integer


  def as_json(options={})
    super({:except => [:address,:contract_point]}.merge(options))
  end

end
