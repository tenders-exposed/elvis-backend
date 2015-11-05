class ContractPoint
  include Mongoid::Document

  # Associations
  embedded_in :procuring_entity, class_name: "ProcuringEntity", inverse_of: :contractPoint

  # Fields
  field :name, type: String
end
