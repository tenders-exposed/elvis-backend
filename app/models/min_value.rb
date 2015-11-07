class MinValue
  include Mongoid::Document

  # Associations
  embedded_in :award, class_name: "Award", inverse_of: :minValue

  # Fields
  field :amount, type: Float
  field :x_amountEur, type: Float
end
