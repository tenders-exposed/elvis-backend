class Network
  include Mongoid::Document

  # Associations
  belongs_to :user, inverse_of: :networks

  #Fields
  field :query, type: Hash
  field :options, type: Hash
  field :name, type: String
  field :description, type: String

end
