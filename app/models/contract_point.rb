class ContractPoint
  include Mongoid::Document

  # Associations
  embedded_in :procuring_entity, class_name: "ProcuringEntity", inverse_of: :contract_point

  # Fields
  field :name, type: String
end
