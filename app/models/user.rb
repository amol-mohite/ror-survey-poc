class User < ApplicationRecord
  require 'securerandom'
  has_secure_password

  has_many :surveys, foreign_key: 'created_by', dependent: :destroy

  validates :email, presence: true
  validates :mobile_no, presence: true
  validates :password, presence: true

  def admin?
    role.to_s == 'admin'
  end
end