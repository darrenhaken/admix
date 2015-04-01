require_relative 'access_token'
require_relative 'access_token_authorisation_error'
require_relative 'access_token_client_error'

class GoogleDriveOAuth2Client

  attr_reader :user_email

  REDIRECT_URI = 'urn:ietf:wg:oauth:2.0:oob'
  CLIENT_SCOPE = 'https://www.googleapis.com/auth/drive'

  NEW_ACCESS_TOKEN_GRANT_TYPE = nil
  REFRESH_ACCESS_TOKEN_GRANT_TYPE = 'refresh_token'

  def initialize(oauth2_client, client_settings)
    @oauth2_client = oauth2_client
    init_client(client_settings)
  end

  def authorization_uri
    @oauth2_client.authorization_uri
  end

  def request_new_access_token(authorization_code)
    @oauth2_client.code = authorization_code
    send_authorization_request_with_grant_type(NEW_ACCESS_TOKEN_GRANT_TYPE)
    @access_token
  end

  def refresh_access_token(refresh_token)
    @oauth2_client.refresh_token = refresh_token
    send_authorization_request_with_grant_type(REFRESH_ACCESS_TOKEN_GRANT_TYPE)
    @access_token.set_refresh_token(refresh_token)
    @access_token
  end

  private
  def send_authorization_request_with_grant_type(grant_type)
    begin
      @oauth2_client.grant_type = grant_type
      send_authorization_request()
    rescue Signet::AuthorizationError => e
      handle_authorization_error(e)
    end
  end

  def send_authorization_request
    access_token_hash = @oauth2_client.fetch_access_token
    @access_token = AccessToken.new(access_token_hash)
    @access_token.set_user_email(@user_email)
  end

  def handle_authorization_error(e)
    if e.message.include?("invalid_client") || e.message.include?('invalid_request')
      raise AccessTokenClientError.new("Incorrect Google Client ID/Secret: #{e.message}")
    end
    raise AccessTokenAuthorisationError.new("Authorization Error: \n#{e.message}")
  end

  def init_client(client_settings)
    @oauth2_client.scope = CLIENT_SCOPE
    @oauth2_client.redirect_uri = REDIRECT_URI
    @oauth2_client.client_id = client_settings.client_id
    @oauth2_client.client_secret = client_settings.client_secret
    @oauth2_client.username = client_settings.user_email
    @user_email = client_settings.user_email
  end

end