require 'time'

class AccessToken

  attr_reader :token, :refresh_token, :user_email

  def initialize(token_hash)
    token_hash = Hash[token_hash.map{ |k, v| [k.to_sym, v] }]
    @token = token_hash[:access_token]
    @expires_in = token_hash[:expires_in]
    @expires_at = token_hash[:expires_at]? token_hash[:expires_at]:(Time.now + @expires_in).to_s
    @refresh_token = token_hash[:refresh_token]
    @user_email = token_hash[:user_email]
  end

  def has_token_expires?
    Time.now > Time.parse(@expires_at)
  end

  def to_hash
    {
        :access_token => @token,
        :refresh_token => @refresh_token,
        :expires_at => @expires_at,
        :expires_in => @expires_in,
        :user_email => @user_email
    }
  end
end
