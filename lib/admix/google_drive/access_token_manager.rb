require 'time'

class AccessTokenAuthorisationError < StandardError

  attr_reader :message

  def initialize(message)
    @message = message
  end

end

class AccessTokenManager

  CLIENT_SCOPE = 'https://www.googleapis.com/auth/drive'

  def initialize(client_authorization, client_setting, store_manager, auth_file)
    init_auth_client(client_authorization, client_setting)
    @store_manager = store_manager
    @auth_file = auth_file
  end

  def get_access_token()
    token_hash = @store_manager.load_stored_credentials(@auth_file)
    unless token_hash.nil?
      if username_eq_user_email(token_hash[:user_email])
        if not is_token_expired?(token_hash[:expires_at])
          return token_hash[:access_token]
        else
          return refresh_access_token(token_hash[:refresh_token])
        end
      end
    end
  end

  def request_new_token(authorization_code)
    begin
      @auth.grant_type = nil
      @auth.code = authorization_code
      token_hash = @auth.fetch_access_token
      @auth.expires_in = token_hash['expires_in']
      @auth.expires_at = Time.now + token_hash['expires_in']
      @auth.access_token = token_hash['access_token']
      @auth.refresh_token = token_hash['refresh_token']
      @store_manager.save_credentials_in_file(@auth, @auth_file)
      @access_token = token_hash['access_token']
    rescue Signet::AuthorizationError
      raise AccessTokenAuthorisationError.new("Wrong authorization code")
    end
  end

  private

  def username_eq_user_email(user_email)
    @auth.username == user_email
  end

  def refresh_access_token(refresh_token)
    @auth.grant_type = 'refresh_token'
    @auth.refresh_token = refresh_token
    token_hash = @auth.fetch_access_token
    @auth.expires_in = token_hash['expires_in']
    @auth.expires_at = Time.now + token_hash['expires_in']
    @auth.access_token = token_hash['access_token']
    @store_manager.save_credentials_in_file(@auth, @auth_file)
    @access_token = token_hash['access_token']
  end

  def is_token_expired?(date)
    Time.now > Time.parse(date)
  end

  def init_auth_client(client_authorization, client_settings)
    @auth = client_authorization
    @auth.scope = CLIENT_SCOPE
    @auth.redirect_uri = 'urn:ietf:wg:oauth:2.0:oob'
    @auth.client_id = client_settings.client_id
    @auth.client_secret = client_settings.client_secret
    @auth.username = client_settings.user_email
  end
end