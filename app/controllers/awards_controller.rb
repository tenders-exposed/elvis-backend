class AwardsController < ApplicationController

  def index
    awards = Award.es.search({})

    render json: awards.results, serializer: AwardSerializer
  end


  def award_params
    params.require(:award).permit(:country, :cpv, :year)
  end
end
