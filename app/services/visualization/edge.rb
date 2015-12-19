class Edge
  attr_accessor :from,  :to, :arrows

  def initialize(from, to)
    @from = from
    @to = to
    @arrows = arrows
  end

  def arrows
    { middle:{ scaleFactor: 0.5}, from:true}
  end
end
