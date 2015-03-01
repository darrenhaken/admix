require 'google/api_client'

require_relative '../../../lib/admix/google_drive/authentication_store'
require_relative '../../../lib/admix/google_drive/access_token_manager'

class GoogleController

  attr_reader :access_token

  MAX_RETRIES = 3

  def initialize(google_settings, auth_file)
    @settings = google_settings
    @auth_file = auth_file
  end

  def setup_controller
    store_manager = AuthenticationStore.instance
    client = Google::APIClient.new(:application_name => 'Admix', :application_version => 0.1).authorization
    @token_manager = AccessTokenManager.new(client, @settings, store_manager, @auth_file)
    check_access_token
  end

  private

  def check_access_token
    @access_token = @token_manager.get_access_token
    if @access_token.nil?
      print("> Copy this URL to your browser to grant access to the application: \n")
      print("\n#{@token_manager.authorization_uri}\n")
      print("> Paste authorisation code here: \n")
      retries = 0
      begin
        auth_code = gets.chomp
        @access_token = @token_manager.request_new_token(auth_code)
      rescue AccessTokenAuthorisationError
        if retries < MAX_RETRIES
          print("\n> Authorisation fails Try again: \n")
          retries += 1
          retry
        end
      end
    end
  end

end