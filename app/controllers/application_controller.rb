class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session
  acts_as_token_authentication_handler_for User, fallback: :none
  before_filter :fix_json_params

  private

  def fix_json_params
    if request.format.json?
      body = request.body.read
      request.body.rewind
      params.merge!(ActiveSupport::JSON.decode(body)) unless body == ""
    end
  end
end
