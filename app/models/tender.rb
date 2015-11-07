class Tender
  include Mongoid::Document

  # Associations
  belongs_to :document
  embeds_one :value

  accepts_nested_attributes_for :value

end
