class Vis::Edge
  attr_accessor :from,  :to, :arrows, :value

  def initialize(from, to, value, flags ={})
    @from = from
    @to = to
    @value = value
    #@arrows = arrows
    @flags = flags.slice(:x_same_city)
  end

  #def arrows
  #  { middle:{ scaleFactor: 0.5}, from:true}
  #end
end
