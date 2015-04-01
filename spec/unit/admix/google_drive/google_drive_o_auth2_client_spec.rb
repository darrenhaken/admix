require 'rspec'
require 'google/api_client'

require_relative '../../../../lib/admix/google_drive/google_client_settings'
require_relative '../../../../lib/admix/google_drive/google_drive_o_auth2_client'

RSpec.describe GoogleDriveOAuth2Client do

  def stub_oauth2_client
    @oauth2_client = object_double(Signet::OAuth2::Client.new)
    stub_oauth2_client_setters(@oauth2_client)
    allow(@oauth2_client).to receive(:fetch_access_token)
  end

  def stub_oauth2_client_setters(oauth2_client)
    allow(oauth2_client).to receive(:scope=)
    allow(oauth2_client).to receive(:redirect_uri=)
    allow(oauth2_client).to receive(:client_id=)
    allow(oauth2_client).to receive(:client_secret=)
    allow(oauth2_client).to receive(:username=)
    allow(oauth2_client).to receive(:grant_type=)
    allow(oauth2_client).to receive(:refresh_token=)
    allow(oauth2_client).to receive(:code=)
  end

  before(:each) do
    stub_oauth2_client
    @settings = GoogleClientSettings.new(anything, anything, anything, anything, anything)
    @authorization_client = GoogleDriveOAuth2Client.new(@oauth2_client, @settings)
  end

  describe "Requesting a new access token from the server" do
    before(:each) do
      @new_token_hash_response = {
          "access_token" => "an access token",
          "refresh_token" => 'a refresh token',
          "expires_in" => 3600
      }
      allow(@oauth2_client).to receive(:fetch_access_token){@new_token_hash_response}
    end

    it "Returns AccessToken object when request succeeds" do
      access_token = @authorization_client.request_new_access_token('authorization_code')

      expect(access_token).to be_a AccessToken
      expect(access_token.token).to eq @new_token_hash_response['access_token']
      expect(access_token.refresh_token).to eq @new_token_hash_response['refresh_token']
    end

    it 'Raises AccessTokenAuthorisationError when fails to request new token, and server code is 401' do
      allow(@oauth2_client).to receive(:fetch_access_token).and_raise(Signet::AuthorizationError.new(anything))

      expect{@authorization_client.request_new_access_token(anything)}.to raise_error(AccessTokenAuthorisationError)
    end

    it 'Raises AccessTokenClientError when client is not recognised by the server' do
      allow(@oauth2_client).to receive(:fetch_access_token).and_raise(Signet::AuthorizationError.new('"error" : "invalid_client"'))

      expect{@authorization_client.request_new_access_token(anything)}.to raise_error(AccessTokenClientError)
    end

    it 'Raises AccessTokenClientError when the request is invalid' do
      allow(@oauth2_client).to receive(:fetch_access_token).and_raise(Signet::AuthorizationError.new('"error" : "invalid_request"'))

      expect{@authorization_client.request_new_access_token(anything)}.to raise_error(AccessTokenClientError)
    end

    it "sets grant_type in oauth2_client to nil when fetching an access token" do
      @authorization_client.request_new_access_token('authorization_code')

      expect(@oauth2_client).to have_received(:grant_type=).with(nil)
    end

    it "sets code in oauth2_client to authorization code when fetching an access token" do
      @authorization_client.request_new_access_token('authorization_code')

      expect(@oauth2_client).to have_received(:code=).with('authorization_code')
    end
  end


  describe 'Refreshing an access token' do
    before(:each) do
      @refresh_token_hash_response = {
          "access_token" => "an refreshed access token",
          "expires_in" => 3600
      }
      allow(@oauth2_client).to receive(:fetch_access_token){@refresh_token_hash_response}
    end

    it "Returns AccessToken object with the same given refresh_token when request succeeds" do
      refresh_token = 'refreshing token'
      access_token = @authorization_client.refresh_access_token(refresh_token)

      expect(access_token).to be_a AccessToken
      expect(access_token.token).to eq @refresh_token_hash_response['access_token']
      expect(access_token.refresh_token).to eq refresh_token
    end

    it 'Raises AccessTokenAuthorisationError when fails to refresh token, and server code is 401' do
      allow(@oauth2_client).to receive(:fetch_access_token).and_raise(Signet::AuthorizationError.new(anything))

      expect{@authorization_client.refresh_access_token(anything)}.to raise_error(AccessTokenAuthorisationError)
    end

    it 'Raises AccessTokenClientError when client is not recognised by the server' do
      allow(@oauth2_client).to receive(:fetch_access_token).and_raise(Signet::AuthorizationError.new('"error" : "invalid_client"'))

      expect{@authorization_client.refresh_access_token(anything)}.to raise_error(AccessTokenClientError)
    end

    it 'Raises AccessTokenClientError when the request is invalid' do
      allow(@oauth2_client).to receive(:fetch_access_token).and_raise(Signet::AuthorizationError.new('"error" : "invalid_request"'))

      expect{@authorization_client.refresh_access_token(anything)}.to raise_error(AccessTokenClientError)
    end

    it "sets grant_type in the oauth2_client to 'refresh_token'" do
      @authorization_client.refresh_access_token('refreshing token')

      expect(@oauth2_client).to have_received(:grant_type=).with('refresh_token')
    end

    it "sets refresh_code in the oauth2_client to the given refresh token" do
      refresh_token = 'refreshing token'

      @authorization_client.refresh_access_token(refresh_token)

      expect(@oauth2_client).to have_received(:refresh_token=).with(refresh_token)
    end
  end
end