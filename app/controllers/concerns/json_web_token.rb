require 'jwt'
module JsonWebToken
  extend ActiveSupport::Concern
  SECRET_KEY = 'aa1728f6b9946b09fdd2e5d934358a9fdeddf996b6c3409c12b5a4b81cb5024124916d322a759abe67013577eedcf2a582a01018955ce4b5a448c5d99d0e40ea'

  def jwt_encode(payload, exp=1.days.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY)
  end

  def jwt_decode(token)
    decoded = JWT.decode(token, SECRET_KEY)[0]
    HashWithIndifferentAccess.new decoded
  end
end