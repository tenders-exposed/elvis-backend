class Value
  include Mongoid::Document

  # Associations
  embedded_in :valuable, polymorphic: true

  # Fields
  field :amount, type: Float
  field :currency, type: String
  field :x_vat, type: Float
  field :x_amount_eur, type: Float
  field :x_vatbool, type: String
end
