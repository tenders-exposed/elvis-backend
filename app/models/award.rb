class Award
  include Mongoid::Document

  # Associations
  embedded_in :contract, inverse_of: :award
  embeds_one :date, class_name: "AwardDate", inverse_of: :award

  embeds_one :value, as: :valuable, inverse_of: :valuable
  embeds_one :x_initialValue, class_name: "XInitialValue", inverse_of: :award
  embeds_one :minValue, class_name: "MinValue", inverse_of: :award
  embeds_one :initialValue, class_name: "InitialValue", inverse_of: :award

  accepts_nested_attributes_for :initialValue, :minValue, :value, :x_initialValue, :date


  # Fields
  field :award_id, type: String
  # award_id will be transalted into award.id at export
  field :title, type: String
  field :description, type: String


  def as_json(options={})
    super({:except => [:minValue, :initialValue,
      :x_initialValue]}.merge(options))
  end

end
