class Value
  include Mongoid::Document

  # Associations
  embedded_in :tender, class_name: "Tender", inverse_of: :value

  # Fields
  field :amount, type: Float
  field :currency, type: String
  field :x_vat, type: Float
  field :x_amountEur, type: Float
  field :x_vatbool, type: Boolean
end
