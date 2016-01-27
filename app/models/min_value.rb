class MinValue
  include Mongoid::Document

  # Associations
  embedded_in :award, class_name: "Award", inverse_of: :min_value

  # Fields
  field :amount, type: Float
  field :x_amount_eur, type: Float
end
