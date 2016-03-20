class Address
  include Mongoid::Document

  # Associations
  embedded_in :addressable, polymorphic: true

  # Fields
  field :country_name, type: String
  field :locality, type: String
  field :street_address, type: String
  field :postal_code, type: String
  field :email, type: String
  field :telephone, type: String
  field :x_url, type: String


end
