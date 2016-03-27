class NetworkSerializer < ActiveModel::Serializer
  attributes :id, :query, :options, :name, :description, :user_id, :graph, :count

  def graph
    path = "#{Rails.root}/networks/#{object.id}.bin"
    Marshal::load( File.open(path, "rb"){|f| f.read} )
  end

  def count
    return { nodes_count: graph[:nodes].size, edges_count: graph[:edges].size }
  end
end
