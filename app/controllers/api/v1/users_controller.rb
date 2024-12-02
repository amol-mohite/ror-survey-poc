class Api::V1::UsersController < ApplicationController
  skip_before_action :authenticate_request, only: [:create]
  
  def index 
    @users = User.all
    render json: @users, status: :ok
  end

  def create
    @user = User.new(user_params)
    if @user.save
      token = jwt_encode(user_id: @user.id)
      render json: {token: token, user_id: @user.id, name: @user.name}, status: :created
    else
      render json: {error: @user.errors.full_messages, status: :unprocessable_entity}
    end
  end

  def profile
    render json: @current_user, status: :ok
  end
  
  def update
    if @user.update(user_params)
      render json: @user, status: :ok
    else
      render json: {error: @user.errors.full_messages, status: :unprocessable_entity}
    end
  end


  private
  def user_params
    params.permit(:name, :email, :mobile_no, :password, :role)
  end

end
