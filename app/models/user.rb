class User
  include Mongoid::Document

# Associations
  has_many :networks, inverse_of: :user, dependent: :destroy

# Config
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable,  :validatable, :rememberable, :trackable,
         :async
        #  :omniauthable

  acts_as_token_authenticatable

# Fields
  field :authentication_token

  ## Database authenticatable
  field :email,              type: String, default: ""
  field :encrypted_password, type: String, default: ""

  ## Recoverable
  field :reset_password_token,   type: String
  field :reset_password_sent_at, type: Time

  ## Rememberable
  field :remember_created_at, type: Time

  ## Trackable
  field :sign_in_count,      type: Integer, default: 0
  field :current_sign_in_at, type: Time
  field :last_sign_in_at,    type: Time
  field :current_sign_in_ip, type: String
  field :last_sign_in_ip,    type: String

  ## Confirmable
  field :confirmation_token,   type: String
  field :confirmed_at,         type: Time
  field :confirmation_sent_at, type: Time
  field :unconfirmed_email,    type: String # Only if using reconfirmable

end
