class Supplier
  include Mongoid::Document

  # Associations
  embedded_in :contract
  embeds_one :address, as: :addressable, inverse_of: :addressable

  # Fields
  field :name, type: String
  field :x_slug, type: String
  field :slug_id, type: Integer

  def as_json(options={})
    super({:except => [:address]}.merge(options))
  end
end
