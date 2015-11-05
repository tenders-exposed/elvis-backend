class AwardDate
  include Mongoid::Document

  # Associations
  embedded_in :award, class_name: "Award", inverse_of: :date

  # Fields
  field :x_year, type: Integer
  field :x_month, type: Integer
  field :x_day, type: Integer
end
