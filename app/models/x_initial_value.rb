class XInitialValue
  include Mongoid::Document

  # Associations
  embedded_in :award, class_name: "Award", inverse_of: :x_initialValue

  # Fields
  field :x_amountEur, type: Float
  field :x_vatbool, type: String
  field :amount, type: Float
  field :currency, type: String
  field :x_vat, type: Float
end
