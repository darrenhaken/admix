require 'google/api_client'

require_relative '../../../lib/admix/google_drive/access_token_file_store'
require_relative '../../../lib/admix/google_drive/access_token_manager'
require_relative '../../../lib/admix/google_drive/google_drive_o_auth2_client'
require_relative '../../../lib/admix/google_drive/google_worksheet_wrapper'
require_relative '../../../lib/admix/cumulative_flow_diagram_logic/cfd_data_point_to_column_mapper'

class GoogleController

  attr_reader :access_token

  MAX_RETRIES = 3

  def initialize(google_settings, auth_file)
    @settings = google_settings
    @auth_file = auth_file
  end

  def setup_controller
    store_manager = AccessTokenFileStore.instance
    google_client = Google::APIClient.new(:application_name => 'Admix', :application_version => 0.1).authorization
    @oauth2_client = GoogleDriveOAuth2Client.new(google_client, @settings)
    @token_manager = AccessTokenManager.new(@oauth2_client, store_manager, @auth_file)
  end

  def access_token
    check_access_token
    @access_token
  end

  private

  def check_access_token
    begin
      @access_token = @token_manager.get_access_token
      if @access_token.nil?
        request_token
      end
    rescue AccessTokenClientError => e
      print("\n#{e.message}\n")
      exit(-1)
    end
  end

  def request_token
    print_authorization_url
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
      exit(-1)
    end
  end

  def print_authorization_url
    print("> Copy this URL to your browser to grant access to the application: \n")
    print("\n#{@token_manager.authorization_uri}\n")
    print("> Paste authorisation code here: \n")
  end
end