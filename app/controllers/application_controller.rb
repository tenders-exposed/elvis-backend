class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session

  def nothing
    render json: '{}', content_type: 'application/json'
  end

end
