class Supplier
  include Mongoid::Document

  # Associations
  belongs_to :document
  has_one :address, as: :addressable, dependent: :destroy

  # Fields
  field :name, type: String
  field :x_slug, type: String
end
