class Award
  include Mongoid::Document

  # Associations
  belongs_to :document
  embeds_one :value, class_name: "Value", inverse_of: :award
  embeds_one :date, class_name: "AwardDate", inverse_of: :award

  # Fields
  field :award_id, type: String
  # award_id will be transalted into award.id at export
  field :title, type: String
  field :description, type: String

end
