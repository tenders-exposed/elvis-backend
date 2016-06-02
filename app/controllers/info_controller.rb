class InfoController < ApplicationController

# This is for clients to check that the API is up and running
  def ping
    render json: {}, status: 200
  end

end
