class Vis::Node
  attr_accessor :id, :value, :label, :color, :type, :flags

# FIXME:Remove me after the user has the ability to choose his own colors
  COLORS = {procuring_entity: 'red', supplier: 'blue'}

  def initialize(id, label, value, type, flags = {})
    @id = id
    @value = value
    @label = label
    @type = type
    @color = COLORS[@type.to_sym]
    @flags = flags.slice(:median)
  end

end
