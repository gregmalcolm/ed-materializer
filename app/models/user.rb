class User < ActiveRecord::Base
  # Include default devise modules.
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :trackable,
         :validatable,
         :confirmable,
         :omniauthable
  include DeviseTokenAuth::Concerns::User

  validates :name, presence: true
  validates :name, uniqueness: true
end
