class InitialValue
  include Mongoid::Document

  # Associations
  embedded_in :award, class_name: "Award", inverse_of: :initialValue

  # Fields
  field :amount, type: Float
  field :currency, type: String
  field :x_vat, type: Float

end
