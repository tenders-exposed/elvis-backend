class RegistrationsController < Devise::RegistrationsController
  skip_before_filter :authenticate_scope!, only: [ :update, :destroy]
  before_filter :authenticate_user!, only: [ :update, :destroy]
  clear_respond_to
  respond_to :json

  def destroy
    current_user.destroy
    Devise.sign_out_all_scopes ? sign_out : sign_out(:user)
    head :no_content
  end

end
