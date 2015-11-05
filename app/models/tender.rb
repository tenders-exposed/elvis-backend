class Tender
  include Mongoid::Document

  # Associations
  belongs_to :document
  embeds_one :initialValue, class_name: "InitialValue", inverse_of: :tender
  embeds_one :minValue, class_name: "MinValue", inverse_of: :tender
  embeds_one :value
  embeds_one :x_initialValue, class_name: "XInitialValue", inverse_of: :tender

  accepts_nested_attributes_for :initialValue, :minValue, :value, :x_initialValue

end
