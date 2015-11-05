class XInitialValue
  include Mongoid::Document

  # Associations
  embedded_in :tender, class_name: "Tender", inverse_of: :x_initialValue

  # Fields
  field :x_amountEur, type: Float
  field :x_vatbool, type: Boolean
end
