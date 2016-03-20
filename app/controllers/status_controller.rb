class StatusController < ApplicationController

  def ok
    render json: {:status => "All is jolly"}, status: 200
  end

end
