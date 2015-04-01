require 'time'
require_relative 'access_token_authorisation_error'
require_relative 'access_token_client_error'
require_relative 'access_token'

class AccessTokenManager

  def initialize(authorization_client, store_manager, auth_file)
    @oauth2_client = authorization_client
    @store_manager = store_manager
    @auth_file = auth_file
  end

  def get_access_token
    token_hash = @store_manager.load_stored_credentials(@auth_file)

    unless token_hash.nil?
      @access_token = AccessToken.new(token_hash)
      return retrieve_access_token
    end
  end

  def request_new_token(authorization_code)
    @access_token = @oauth2_client.request_new_access_token(authorization_code)
    @store_manager.save_credentials_in_file(@access_token.to_hash, @auth_file)
    @access_token.token
  end

  def authorization_uri
    @oauth2_client.authorization_uri
  end

  private
  def refresh_access_token
    @oauth2_client.refresh_access_token(@access_token.refresh_token)
  end

  def retrieve_access_token
    if @oauth2_client.user_email == @access_token.user_email
      if @access_token.has_token_expired?
        @access_token = refresh_access_token
        @store_manager.save_credentials_in_file(@access_token.to_hash, @auth_file)
      end
      return @access_token.token
    end
  end
end