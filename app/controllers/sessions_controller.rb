class SessionsController < Devise::SessionsController
  clear_respond_to
  respond_to :json
end
