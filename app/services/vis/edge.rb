class Vis::Edge
  attr_accessor :from,  :to, :arrows, :value

  def initialize(from, to, value, flags ={})
    @from = from
    @to = to
    @value = value
    @arrows = arrows
    @flags = flags.slice(:no_tenderers, :percent_contracts)
  end

  def arrows
    { middle:{ scaleFactor: 0.5}, from:true}
  end
end
