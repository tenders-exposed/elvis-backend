class ErrorsController < ApplicationController
  def not_found
    render json: {:error => "Not found"}, status: 404
  end

  def unauthorized
    render json: {:error => "Unauthorized"}, status: 401
  end

  def internal_server_error
    render json: {:error => "Internal server error"}, status: 500
  end

  def unprocessible_entity
    render json: {error: "Unprocessible entity"}, status: 422
  end

end
