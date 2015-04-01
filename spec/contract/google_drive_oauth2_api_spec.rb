require 'rspec'
require 'json'
require 'google/api_client'

require_relative '../../spec/spec_helper'
require_relative '../../lib/admix/google_drive/google_drive_o_auth2_client'
require_relative '../../lib/admix/google_drive/google_client_settings'

RSpec.describe 'Contract Test for Google::APIClient' do

  before(:all) do
    @client_id = ENV['GOOGLE_CLIENT_ID']
    @client_secret = ENV['GOOGLE_CLIENT_SECRET']
    @user_email = ENV['GOOGLE_EMAIL']
    path_to_assets = "../../assets/"
    @auth_json_file = File.expand_path(path_to_assets + 'auth_data.json', __FILE__)
  end

  after(:all) do
    File.delete(@auth_json_file) if File.exists?(@auth_json_file)
  end

  describe "Return an access token" do

    #TODO find a way to grant access to a client, and generate authorization code for test
    # This involves logging in with the username, accept app access, then forward the authorization code
    # it "Generated a new refresh token and access token when given authorisation code" do
    #
    # end

    it "generates a new access token and returns it when current token has expired" do
      settings = GoogleClientSettings.new(@client_id, @client_secret, @user_email, nil, nil)
      google_auth_client = Google::APIClient.new(:application_name => 'Admix', :application_version => 0.1).authorization
      oauth2_client = GoogleDriveOAuth2Client.new(google_auth_client, settings)
      access_token = oauth2_client.refresh_access_token(ENV["GOOGLE_REFRESH_TOKEN"])

      expect(access_token).to_not be_nil
    end

    it "Throws Signet::AuthorizationError exception when client ID/secert are not recognised by Google server" do
      auth_client = Google::APIClient.new(:application_name =>'Admix', :application_version =>1).authorization
      auth_client.client_secret = 'secret'
      auth_client.grant_type = 'refresh_token'
      auth_client.refresh_token = 'refresh_token'

      auth_client.client_id = 'random id'

      expect{auth_client.fetch_access_token!}.to raise_error(Signet::AuthorizationError, /"error" : "invalid_client"/)
    end

    it "Throws Signet::AuthorizationError exception when a request is not recognised by Google server" do
      auth_client = Google::APIClient.new(:application_name =>'Admix', :application_version =>1).authorization
      auth_client.client_secret = nil
      auth_client.grant_type = 'refresh_token'
      auth_client.refresh_token = 'refresh_token'

      auth_client.client_id = nil

      expect{auth_client.fetch_access_token!}.to raise_error(Signet::AuthorizationError, /"error" : "invalid_request"/)
    end
  end

end