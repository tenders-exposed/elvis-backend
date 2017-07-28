class Supplier
  include Mongoid::Document

  # Associations
  embedded_in :contract
  embeds_one :address, as: :addressable, inverse_of: :addressable

  # Fields
  field :name, type: String
  field :x_slug, type: String, default: nil
  field :x_slug_id, type: Integer, default: nil
  field :x_same_city, type: Integer, default: nil

  def as_json(options={})
    super({:except => [:address]}.merge(options))
  end

  def as_indexed_json
    obj = self.as_json[self.model_name.element].except(:x_slug)
    obj[:type] = self.model_name.element
    obj
  end

end
