class MinValue
  include Mongoid::Document

  # Associations
  embedded_in :tender, class_name: "Tender", inverse_of: :minValue

  # Fields
  field :amount, type: Float
  field :x_amountEur, type: Float
end
