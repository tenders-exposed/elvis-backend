class NetworksSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :user_id, :query, :options
end
