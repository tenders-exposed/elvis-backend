class Vis::Edge
  attr_accessor :from,  :to, :arrows, :value

  def initialize(from, to, value)
    @from = from
    @to = to
    @value = value
    @arrows = arrows
  end

  def arrows
    { middle:{ scaleFactor: 0.5}, from:true}
  end
end
