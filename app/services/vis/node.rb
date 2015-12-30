class Vis::Node
  attr_accessor :id, :value, :label, :color, :type

# FIXME:Remove me after the user has the ability to choose his own colors
  COLORS = {procuring_entity: 'red', supplier: 'blue'}

  def initialize(id, value, type )
    @id = id
    @value = value
    # @label = label
    @type = type
    @color = COLORS[@type.to_sym]
  end

end
