class UsersController < ApplicationController
  before_action :authenticate_user!, except:[:show]

  def show
    user = User.find(params[:id])
    render json: user
  end

  def user_params
    params.require(:user).permit(:id, :email)
  end


end
