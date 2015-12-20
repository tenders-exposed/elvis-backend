class Supplier
  include Mongoid::Document
  include Mongoid::Elasticsearch

  # Associations
  embedded_in :contract
  embeds_one :address, as: :addressable, inverse_of: :addressable

  # Fields
  field :name, type: String
  field :x_slug, type: String

  elasticsearch!({
    prefix_name: false,
    index_name: 'suppliers',
    wrapper: :load
  })
end
