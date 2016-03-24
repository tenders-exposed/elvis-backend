class NetworkSerializer < ActiveModel::Serializer
  attributes :id, :query, :options, :name, :description, :user_id, :graph

  def graph
    path = "#{Rails.root}/networks/#{object.id}.bin"
    Marshal::load( File.open(path, "rb"){|f| f.read} )
  end
end
