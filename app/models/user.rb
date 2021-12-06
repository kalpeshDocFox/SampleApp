class User < ApplicationRecord
  attr_accessor :remember_token
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
            uniqueness: { case_sensitive: false }
  has_secure_password
  
  validates :password,
            presence: true,
            length: { minimum: PASSSWORD_MIN_LENGTH },
            allow_nil: true

  # Returns the hash digest of the given string.
  def self.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
             BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # Remembers a user in the database for use in persistent sessions.
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
    remember_digest
  end

  # Returns a session token to prevent session hijacking. # We reuse the remember digest for convenience.
  def session_token
    remember||remember_digest
  end

  # Returns a random token.
  def self.new_token
    SecureRandom.urlsafe_base64
  end

  # Returns true if the given token matches the digest.
  def authenticated?(remember_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  # New token for a user.
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # Forgets a user.
  def forget
    update_attribute(:remember_digest, nil)
  end
end
