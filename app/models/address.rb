class Address
  include Mongoid::Document

  # Associations
  belongs_to :addressable, polymorphic: true

  # Fields
  field :countryName, type: String
  field :locality, type: String
  field :streetAddress, type: String
  field :postalCode, type: String
  field :email, type: String
  field :telephone, type: String
  field :x_url, type: String
end
