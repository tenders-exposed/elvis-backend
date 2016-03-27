class NetworksSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :user_id
end
