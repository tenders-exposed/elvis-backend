class Supplier
  include Mongoid::Document
  include Mongoid::Elasticsearch

  # Associations
  belongs_to :document
  has_one :address, as: :addressable, dependent: :destroy, autosave: true

  # Fields
  field :name, type: String
  field :x_slug, type: String

  elasticsearch!({
    prefix_name: false,
    index_name: 'suppliers',
    wrapper: :load
  })
end
