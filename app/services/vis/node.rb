class Vis::Node
  attr_accessor :id, :value, :label, :color, :type, :flags

# FIXME:Remove me after the user has the ability to choose his own colors
  COLORS = {procuring_entity: 'rgb(246, 49, 136)', supplier: 'rgb(36, 243, 255)'}

  def initialize(id, label, value, type, average_competition, flags = {})
    @id = id
    @value = value
    @label = label
    @type = type
    @color = COLORS[@type.to_sym]
    @average_competition = average_competition
    @flags = flags.slice(:average_competition)
  end

end
