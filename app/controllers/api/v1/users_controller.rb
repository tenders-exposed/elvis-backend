class Api::V1::UsersController < Api::V1::ApiController
  before_action :authenticate_user!

  def show
    user = User.find(params[:id])
    render json: user
  end

  def user_params
    params.require(:user).permit(:id, :email)
  end


end
