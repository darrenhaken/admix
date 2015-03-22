require 'time'
require_relative 'access_token_authorisation_error'
require_relative 'access_token_client_error'

class AccessTokenManager

  CLIENT_SCOPE = 'https://www.googleapis.com/auth/drive'

  def initialize(client_authorization, client_setting, store_manager, auth_file)
    init_auth_client(client_authorization, client_setting)
    @store_manager = store_manager
    @auth_file = auth_file
  end

  def get_access_token
    token_hash = @store_manager.load_stored_credentials(@auth_file)

    unless token_hash.nil?
      if @auth.username == token_hash[:user_email]
        if is_token_expired?(token_hash[:expires_at])
          return refresh_access_token(token_hash[:refresh_token])
        else
          return token_hash[:access_token]
        end
      end
    end
  end

  def request_new_token(authorization_code)
    @auth.grant_type = nil
    @auth.code = authorization_code
    send_authorization_request
  end

  def authorization_uri
    @auth.authorization_uri
  end

  private

  def refresh_access_token(refresh_token)
    @auth.grant_type = 'refresh_token'
    @auth.refresh_token = refresh_token
    send_authorization_request
  end

  def update_authorization_client(token_hash)
    @auth.expires_in = token_hash['expires_in']
    @auth.expires_at = Time.now + token_hash['expires_in']
    @auth.access_token = token_hash['access_token']
    if token_hash.has_key?('refresh_token')
      @auth.refresh_token = token_hash['refresh_token']
    end
  end

  def send_authorization_request
    begin
      token_hash = @auth.fetch_access_token
      update_authorization_client(token_hash)
      @store_manager.save_credentials_in_file(@auth, @auth_file)
      @access_token = token_hash['access_token']
    rescue Signet::AuthorizationError => e
      if e.message.include?("invalid_client")
        raise AccessTokenClientError.new("Incorrect Google Client ID/Secret")
      end
      raise AccessTokenAuthorisationError.new("Authorization Error: \n#{e.message}")
    end
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