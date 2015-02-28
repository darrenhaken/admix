require 'rspec'
require 'google/api_client'

require_relative '../../../lib/admix/google_drive/access_token_manager'

RSpec.describe AccessTokenManager do

  def stub_authentication_client
    @auth_client = double("Google::APIClient.client_authorisation")
    allow(@auth_client).to receive(:grant_type=)
    allow(@auth_client).to receive(:scope=)
    allow(@auth_client).to receive(:redirect_uri=)
    allow(@auth_client).to receive(:client_id=)
    allow(@auth_client).to receive(:client_secret=)
    allow(@auth_client).to receive(:username=)
    allow(@auth_client).to receive(:username){'anything'}
    allow(@auth_client).to receive(:expires_at=)
    allow(@auth_client).to receive(:expires_in=)
    allow(@auth_client).to receive(:access_token=)
    allow(@auth_client).to receive(:access_token)
    allow(@auth_client).to receive(:refresh_token=)
    allow(@auth_client).to receive(:fetch_access_token)
  end

  def stub_client_settings
    @settings = double("GoogleClientSettings")
    allow(@settings).to receive(:client_id).and_return(anything)
    allow(@settings).to receive(:client_secret).and_return(anything)
    allow(@settings).to receive(:user_email).and_return(anything)
  end

  def stub_store_manager
    @store = double("AuthenticationStore")
    allow(@store).to receive(:save_credentials_in_file).with(anything, anything)

  end

  describe "Initialise  AccessTokenManager" do

    before(:each) do
      stub_authentication_client
      stub_client_settings
      stub_store_manager
    end

    it "accepts 4 params for initialising AccessTokenManager" do
      manager = AccessTokenManager.new(@auth_client, @settings ,@store, anything)

      expect(manager).to_not be_nil
    end
  end

  describe "Return an access token" do

    before(:each) do
      stub_authentication_client
      stub_client_settings
      stub_store_manager
      @manager = AccessTokenManager.new(@auth_client, @settings ,@store, anything)
      @token_hash = {:access_token => 'access token in stored in a file',
                     :refresh_token => 'refresh token',
                     :expires_at => (Time.now + 3600).to_s,
                     :user_email => 'anything'}
      @fetched_token = { 'access_token' => 'new fresh token generated',
                         'expires_in' => 3600 }
    end

    it "Return an access token when it is found by AuthenticationStore" do
      allow(@store).to receive(:load_stored_credentials){@token_hash}

      expect(@manager.get_access_token).to eq 'access token in stored in a file'
    end


    it "Refreshes token when access_token is found, but expired" do
      @token_hash = @token_hash.update(:expires_at => (Time.now - 3600).to_s)
      allow(@store).to receive(:load_stored_credentials){@token_hash}

      allow(@auth_client).to receive(:fetch_access_token) {@fetched_token}

      expect(@manager.get_access_token).to eq 'new fresh token generated'
    end

    it "calls store manager to store the new refresh token when it is received" do
      @token_hash = @token_hash.update(:expires_at => (Time.now - 3600).to_s)
      allow(@store).to receive(:load_stored_credentials){@token_hash}

      allow(@auth_client).to receive(:fetch_access_token) {@fetched_token}

      @manager.get_access_token

      expect(@store).to have_received(:save_credentials_in_file).with(@auth_client, anything)
    end

    it "Return nil when file is not found by AuthenticationStore" do
      allow(@store).to receive(:load_stored_credentials){nil}

      expect(@manager.get_access_token).to be_nil
    end

    it "Returns nil when the username in file is different from the user_name in AuthorisationSettings" do
      allow(@settings).to receive(:user_email).and_return('username_from_settings')

      allow(@auth_client).to receive(:username=).with('username_from_settings')
      allow(@auth_client).to receive(:username){'username_from_settings'}

      allow(@store).to receive(:load_stored_credentials){{:user_email => 'user email from file'}}

      expect(@manager.get_access_token).to be_nil
    end
  end

  describe "Request new token" do

    before(:each) do
      stub_authentication_client
      stub_client_settings
      stub_store_manager
      @manager = AccessTokenManager.new(@auth_client, @settings ,@store, anything)
      @fetched_token = {'expires_in' => 3600,
                        'access_token' => 'newly generated access token',
                        'refresh_token' => 'new refresh_token' }
    end

    it 'requests new token and return the access token' do
      allow(@auth_client).to receive(:grant_type=).with(nil)
      allow(@auth_client).to receive(:code=).with('authorization code')
      allow(@auth_client).to receive(:expires_in=).with(@fetched_token['expired_in'])
      allow(@auth_client).to receive(:access_token=).with(@fetched_token['access_token'])
      allow(@auth_client).to receive(:refresh_token=).with(@fetched_token['refresh_token'])
      allow(@auth_client).to receive(:fetch_access_token).and_return(@fetched_token)

      expect(@manager.request_new_token('authorization code')).to eq 'newly generated access token'
    end

    it 'stores the token details after it is received' do
      allow(@auth_client).to receive(:grant_type=).with(nil)
      allow(@auth_client).to receive(:code=).with('authorization code')
      allow(@auth_client).to receive(:expires_in=).with(@fetched_token['expired_in'])
      allow(@auth_client).to receive(:access_token=).with(@fetched_token['access_token'])
      allow(@auth_client).to receive(:refresh_token=).with(@fetched_token['refresh_token'])
      allow(@auth_client).to receive(:fetch_access_token).and_return(@fetched_token)

      @manager.request_new_token('authorization code')

      expect(@store).to have_received(:save_credentials_in_file).with(@auth_client, anything)
    end

    it 'stores the token details after it is received' do
      allow(@auth_client).to receive(:code=).with('authorization code')
      allow(@auth_client).to receive(:fetch_access_token).and_raise(Signet::AuthorizationError.new(anything))

      expect{@manager.request_new_token('authorization code')}.to raise_error(AccessTokenAuthorisationError)
    end

  end
end