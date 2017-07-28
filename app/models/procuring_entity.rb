class ProcuringEntity
  include Mongoid::Document

  # Associations
  embedded_in :contract, inverse_of: :procuring_entity
  embeds_one :address, as: :addressable, inverse_of: :addressable
  embeds_one :contract_point, class_name: "ContractPoint", inverse_of: :procuring_entity

  accepts_nested_attributes_for :contract_point

  # Fields
  field :name, type: String
  field :x_slug, type: String, default: nil
  field :x_type, type: String
  field :x_slug_id, type: Integer, default: nil

  def as_json(options={})
    super({:except => [:address,:contract_point]}.merge(options))
  end

  def as_indexed_json
    obj = self.as_json[self.model_name.element].except(:x_slug)
    obj[:type] = self.model_name.element
    obj
  end
end
