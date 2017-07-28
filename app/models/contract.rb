class Contract
  include Mongoid::Document
  include Mongoid::Elasticsearch

  elasticsearch!

  # Associations
  embeds_one  :tender, inverse_of: :contract
  embeds_one  :award, inverse_of: :contract
  embeds_one  :procuring_entity, inverse_of: :contract
  embeds_many :suppliers, inverse_of: :contract

  # Indexes
  index({ "procuring_entity.x_slug": "hashed" }, {name: "procurer_xslug_index" })

  # Fields
  field :contract_id, type: String
  field :additional_identifiers, type: String
  field :award_criteria, type: String
  field :procurement_method, type: String
  field :x_CPV, type: Array
  field :x_NUTS, type: String
  field :x_eu_project, type: String
  field :x_framework, type: String
  field :x_subcontracted, type: Boolean
  field :number_of_tenderers, type: Integer
  field :x_lot, type: String
  field :x_additional_information, type: String
  field :x_url, type: String
  field :contract_number, type: String

  accepts_nested_attributes_for :procuring_entity, :suppliers

  def as_json(options={})
    result = super({:except => [:additional_identifiers, :contract_id, :x_lot,
      :x_additional_information, :x_url, :contract_number, :x_NUTS] }.merge(options))
    result[:award] = award.as_json
    result[:suppliers] = suppliers.map{|s| s.as_json}
    result[:procuring_entity] = procuring_entity.as_json
    result
  end

  def as_indexed_json
    self.as_json[self.model_name.element]
  end

end
