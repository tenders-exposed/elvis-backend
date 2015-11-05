class ProcuringEntity
  include Mongoid::Document

  # Associations
  belongs_to :document
  has_one :address, as: :addressable, dependent: :destroy
  embeds_one :contractPoint, class_name: "ContractPoint", inverse_of: :procuring_entity

  # Fields
  field :name, type: String
  field :x_slug, type: String
  field :x_type, type: String

end
