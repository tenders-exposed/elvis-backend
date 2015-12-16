class Elastic::CpvsController < ApplicationController

  def autocomplete
    cpvs = Search::CpvSearch.new().get_suggestions(cpv_params[:code])
    render json: cpvs
  end

  def cpv_params
    params.permit(:code)
  end
end
