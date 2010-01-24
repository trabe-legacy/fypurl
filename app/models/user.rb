require 'digest/sha1'

class User < ActiveRecord::Base

  RESERVED_LOGINS = %w(home unknown_user user_has_no_url login signup activate_account logout admin forgotten_password fyp unfyp login_express fyp_express unfyp_express legal_info)

  attr_accessor :password
  attr_accessor :terms_of_use_acceptance
  attr_accessor :new_password

  validates_presence_of :login,
      :message => 'You must choose a <strong>login</strong>'

  validates_length_of :login,
      :within => 3..40,
      :if => Proc.new { |user| !user.login.blank?},
      :too_long => 'The <strong>login</strong> is too long. Cannot have more than 40 characters',
      :too_short => 'The <strong>login</strong> is too short. Cannot have less than 3 characters'

  validates_format_of :login,
      :with => /\A(\w|_)+\z/,
      :if => Proc.new { |user| !user.login.blank?},
      :message => "The <strong>login</strong> contains characters that aren't allowed. " +
          "Use only letters, numbers or underscores"

  validates_uniqueness_of :login,
      :case_sensitive => false,
      :message => 'We\'re sorry. The <strong>login</strong> has already been taken. Try another one'

  validates_exclusion_of :login, :in => RESERVED_LOGINS,
      :message => "We're sorry. That <strong>login</strong> cannot be taken by anyone. Try another one"

  validates_presence_of :password,
      :if => Proc.new { |user| user.new_password && !user.login.blank?},
      :message => 'You must choose a <strong>password</strong>'

  validates_length_of :password,
      :within => 4..32,
      :if => Proc.new { |user| user.new_password && !user.password.blank? },
      :too_long => 'The <strong>password</strong> is too long. Cannot have more than 32 characters',
      :too_short => 'The <strong>password</strong> is too short. Cannot have less than 4 characters'

  validates_confirmation_of :password,
      :if => Proc.new { |user| user.new_password && !user.password.blank? },
      :message => 'The <strong>password</strong> doesn\'t match the <strong>confirmation</strong>'

  validates_presence_of :email,
      :message => 'You must provide an <strong>e-mail</strong>'

  validates_uniqueness_of :email,
      :case_sensitive => false,
      :message => 'We\'re sorry. That <strong>email</strong> is already being used. Try another one'

  validates_acceptance_of :terms_of_use_acceptance,
      :message => 'You must accept the <strong>terms of use</strong>'

  validates_format_of :email,
      :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i,
      :message => 'The <strong>e-mail</strong> seems to be wrong'

  before_create :make_activation_code
  before_save :encrypt_password

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = find :first, :conditions => ['login = ? and activated_at IS NOT NULL', login]
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    self.remember_token_expires_at = 4.weeks.from_now.utc
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

  # Activates the user in the database.
  def activate
    @activated = true
    update_attributes(:activated_at => Time.now.utc, :activation_code => nil)
  end

  # Returns true if the user has just been activated.
  def recently_activated?
    @activated
  end

  #
  #
  #
  def new_random_password
    self.password= Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--")[0,8]
    password = self.password_confirmation = self.password
    self.new_password = false
    self.save
    password
  end

  protected
  # before filter
  def encrypt_password
    return if password.blank?
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
    self.crypted_password = encrypt(password)
  end

  def password_required?
    crypted_password.blank? || !password.blank?
  end

  def make_activation_code
    self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
  end
end
