class Visualization::Node
  attr_accessor :id, :value, :label, :color

# FIXME:Remove me after the user has the ability to choose his own colors
  COLORS = {procuring_entity: [255,0,0], supplier: [0,0,255]}

  def initialize(id, value, label, options = {})
    @id = id
    @value = value
    @label = label
    @color = options[:color]
  end

end
