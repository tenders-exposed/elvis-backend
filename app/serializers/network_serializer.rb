class NetworkSerializer < ActiveModel::Serializer
  attributes :id, :query, :options, :name, :description, :user_id, :graph, :count

  def graph
    path = "#{Rails.root}/networks/#{object.id}.bin"
    Marshal::load( File.open(path, "rb"){|f| f.read} )
  end

  def count
    nodes_count = graph[:nodes].nil? ? 0 : graph[:nodes].size
    edges_count = graph[:edges].nil? ? 0 : graph[:edges].size
    return { nodes_count: nodes_count, edges_count: edges_count }
  end
end
