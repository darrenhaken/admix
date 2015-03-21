require 'rspec'
require 'json'
require 'google/api_client'

require_relative '../../spec/spec_helper'
require_relative '../../lib/admix/google_drive/access_token_manager'
require_relative '../../lib/admix/google_drive/authentication_store'

RSpec.describe 'Contract Test for Google::APIClient' do

  before(:all) do
    @client_id = ENV['GOOGLE_CLIENT_ID']
    @client_secret = ENV['GOOGLE_CLIENT_SECRET']
    @user_email = ENV['GOOGLE_EMAIL']
    @path_to_assets = "../../../assets/"
    @auth_json_file = File.expand_path(@path_to_assets + 'auth_data.json', __FILE__)
  end

  def create_file(file, access_token = "random", refresh_token="random",
                  expires_at=(Time.now + 3600), user_email=@user_email)
    token_hash = {:access_token => access_token,
                  :refresh_token => refresh_token,
                  :expires_in => 3600,
                  :expires_at => expires_at.to_s,
                  :user_email => user_email
    }
    File.open(file, 'w+') do |f|
      f.write(JSON.pretty_generate(token_hash))
    end
  end


  after(:all) do
    File.delete(@auth_json_file)
  end

  describe "Return an access token" do

    #TODO find a way to grant access to a client, and generate authorization code for test
    # This involves logging in with the username, accept app access, then forward the authorization code
    # it "Generated a new refresh token and access token when given authorisation code" do
    #
    # end

    it "generates a new access token and returns it when current token has expired" do
      create_file(@auth_json_file, nil, ENV['GOOGLE_REFRESH_TOKEN'], "2015-02-15 09:23:22 +0000")
      settings = double("GoogleSetting", :client_id => @client_id, :client_secret => @client_secret, :user_email => @user_email)
      store_manager = AuthenticationStore.instance
      client = Google::APIClient.new(:application_name => 'Admix', :application_version => 0.1).authorization
      manager = AccessTokenManager.new(client, settings, store_manager, @auth_json_file)

      access_token = manager.get_access_token

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

  end

end