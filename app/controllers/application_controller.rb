class ApplicationController < ActionController::API
  include JsonWebToken

  before_action :authenticate_request

  private 

  def authenticate_request
    header = request.headers['Authorization']
    if header.blank?
      return render json: { error: 'Authorization Access' }, status: :unauthorized
    end

    token = header.split(' ').last
    begin
      decoded = jwt_decode(token)
      @current_user = User.find(decoded[:user_id])
    rescue JWT::DecodeError
      render json: { error: 'Invalid or missing token' }, status: :unauthorized
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'User not found' }, status: :unauthorized
    end
  end
end
