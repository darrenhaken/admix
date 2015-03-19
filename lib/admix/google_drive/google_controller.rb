require 'google/api_client'

require_relative '../../../lib/admix/google_drive/authentication_store'
require_relative '../../../lib/admix/google_drive/access_token_manager'
require_relative '../../../lib/admix/google_drive/google_sheet_helper'
require_relative '../../../lib/admix/google_drive/google_sheet_column_mapper'

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

  def insert_cfd_to_spreadsheet(cdf)
    check_access_token
    @spreadsheet_helper = GoogleSheetHelper.new(@access_token, @settings.spreadsheet_title, @settings.worksheet_title)
    @spreadsheet_helper.update_cfd_for_day_date_column!(cdf, GoogleSheetColumnMapper.mapping)
    @spreadsheet_helper.write_data_to_worksheet_with_mapping(cdf, GoogleSheetColumnMapper.mapping)
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