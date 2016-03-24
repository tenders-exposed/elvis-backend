class NetworkSerializer < ActiveModel::Serializer
  attributes :query, :options, :name, :description, :user_id
  # , :graph

  # def graph
  #   path = "#{Rails.root}/networks/#{@network.id}.bin"
  #   Marshal::load( File.open(path, "rb"){|f| f.read} )
  #   # .as_json
  # end
end
