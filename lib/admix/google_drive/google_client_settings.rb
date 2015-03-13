class GoogleClientSettings

  attr_reader :client_id, :client_secret, :user_email

  def initialize(client_id, client_secret, user_email)
    @client_id = client_id
    @client_secret = client_secret
    @user_email = user_email
  end

  def self.SETTING_KEYS
    ['client_account', 'client_secret', 'user_email']
  end
end