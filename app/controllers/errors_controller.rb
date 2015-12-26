class ErrorsController < ApplicationController
  def not_found
    render :json => {:error => "The object was not found"}.to_json, :status => 404
  end

  def internal_server_error
    render :json => {:error => "Internal server error"}.to_json, :status => 500
  end

  def unprocessible_entity
    render :json => {:error => "Unprocessible entity"}.to_json, :status => 422
  end

end
