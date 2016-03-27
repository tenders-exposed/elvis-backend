class ConfirmationsController < Devise::ConfirmationsController
  clear_respond_to
  respond_to :json

end
