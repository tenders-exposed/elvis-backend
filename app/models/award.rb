class Award
  include Mongoid::Document
  include Mongoid::Elasticsearch

  # Associations
  belongs_to :document
  embeds_one :date, class_name: "AwardDate", inverse_of: :award

  embeds_one :value, class_name: "Value", inverse_of: :award
  embeds_one :x_initialValue, class_name: "XInitialValue", inverse_of: :award
  embeds_one :minValue, class_name: "MinValue", inverse_of: :award
  embeds_one :initialValue, class_name: "InitialValue", inverse_of: :award

  accepts_nested_attributes_for :initialValue, :minValue, :value, :x_initialValue, :date


  # Fields
  field :award_id, type: String
  # award_id will be transalted into award.id at export
  field :title, type: String
  field :description, type: String

  elasticsearch!({
    prefix_name: false,
    index_name: 'awards',
    wrapper: :load
  })

  def as_indexed_json
    {
      country: document.procuring_entity.address.countryName,
      cpvs: document.x_CPV,
      award_id: award_id,
      title: title,
      description: description,
      initialValue: initialValue,
      minValue: minValue,
      value: value,
      x_initialValue: value,
      date: date
    }
  end
end
