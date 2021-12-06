class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token 
  before_save :downcase_email
  before_create :create_activation_digest
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

  # Returns true if the given token matches the digest. 
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil? 
    BCrypt::Password.new(digest).is_password?(token)
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

  # New token for a user.
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # Converts email to all lower-case.
  def downcase_email
    self.email = email.downcase
  end

  # Creates and assigns the activation token and digest.
  def create_activation_digest
    self.activation_token = User.new_token 
    self.activation_digest = User.digest(activation_token)
  end

  # Forgets a user.
  def forget
    update_attribute(:remember_digest, nil)
  end

  # Activates an account. 
  def activate
    update_columns(activated: true , activated_at: Time.zone.now)
  end

  # Sends activation email.
  def send_activation_email 
    UserMailer.account_activation(self).deliver_now
  end

end
