class Tender
  include Mongoid::Document

  # Associations
  embedded_in :contract, inverse_of: :tender
  embeds_one :value, as: :valuable, inverse_of: :valuable

  accepts_nested_attributes_for :value

end
