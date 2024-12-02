class Api::V1::SessionsController < ApplicationController
  skip_before_action :authenticate_request

  def create 
    @user = User.find_by_email(params[:email])
    if @user&.authenticate(params[:password])
      token = jwt_encode(user_id: @user.id)
      render json: {token: token, user_id: @user.id, name: @user.name, role: @user.role}, status: :ok
    else
      render json: {error: 'Unauthorized Access'}, status: :unprocessable_entity
    end
  end
end
