class Tender
  include Mongoid::Document
  include Mongoid::Elasticsearch


  # Associations
  embedded_in :document, inverse_of: :tender
  embeds_one :value

  accepts_nested_attributes_for :value

  elasticsearch!({
    prefix_name: false,
    index_name: 'tenders',
    wrapper: :load
  })

end
