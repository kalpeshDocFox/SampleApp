class User < ApplicationRecord
  PASSSWORD_MIN_LENGTH = 6
  NAME_MAX_LENGTH = 51
  EMAIL_MAX_LENGTH = 255
  before_save { email.downcase! }
  validates :name,
            presence: true,
            length: { maximum: NAME_MAX_LENGTH.pred }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email,
            presence: true,
            length: { maximum: EMAIL_MAX_LENGTH },
            format: { with: VALID_EMAIL_REGEX },
            uniqueness: true,
            uniqueness: { case_sensitive: false }
  has_secure_password
  validates :password,
            presence: true,
            length: { minimum: PASSSWORD_MIN_LENGTH }
  # Returns the hash digest of the given string.
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
             BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end
end
