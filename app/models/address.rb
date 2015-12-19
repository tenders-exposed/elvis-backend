class Address
  include Mongoid::Document

  # Associations
  embedded_in :addressable, polymorphic: true

  # Fields
  field :countryName, type: String
  field :locality, type: String
  field :streetAddress, type: String
  field :postalCode, type: String
  field :email, type: String
  field :telephone, type: String
  field :x_url, type: String
  field :country, type: String

  # Callbacks
  # before_create :country_full_name

  protected

  # def country_full_name
  #   store = Redis::HashKey.new('countries')
  #   country = store.get(countryName)
  # end

end
