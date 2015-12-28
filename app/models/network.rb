class Network
  include Mongoid::Document

  # Associations
  belongs_to :user, inverse_of: :networks

  #Fields
  field :query, type: Hash
  field :name, type: String, default: "My network"
  field :options, type: Hash
  field :graph, type: Hash

end
