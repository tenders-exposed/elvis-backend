class Award
  include Mongoid::Document

  # Associations
  embedded_in :contract, inverse_of: :award
  embeds_one :date, class_name: "AwardDate", inverse_of: :award

  embeds_one :value, as: :valuable, inverse_of: :valuable
  embeds_one :x_initial_value, class_name: "XInitialValue", inverse_of: :award
  embeds_one :min_value, class_name: "MinValue", inverse_of: :award

  accepts_nested_attributes_for :min_value, :value, :x_initial_value, :date

  # Fields
  field :award_id, type: String
  field :title, type: String
  field :description, type: String


  def as_json(options={})
    super({:except => [:min_value, :x_initial_value]}.merge(options))
  end

end
