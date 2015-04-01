require 'rspec'
require 'google/api_client'

require_relative '../../../../lib/admix/google_drive/access_token_manager'
require_relative '../../../../lib/admix/google_drive/authentication_store'

RSpec.describe AccessTokenManager do

  def stub_store
    @store = object_double(AuthenticationStore.instance)
    allow(@store).to receive(:load_stored_credentials){@stored_token_hash}
    allow(@store).to receive(:save_credentials_in_file)
  end

  def stub_oauth2_client
    @oauth2_client = double('GoogleDriveOAuth2Client')
    allow(@oauth2_client).to receive(:user_email){@stored_token_hash[:user_email]}
  end

  before(:each) do
    @stored_token_hash = {
        :access_token => 'access token in stored in a file',
        :refresh_token => 'refresh token',
        :expires_in => 3600,
        :expires_at => (Time.now + 3600).to_s,
        :user_email => 'anything'
    }
    @access_token_instance = AccessToken.new(@stored_token_hash.merge(:access_token => 'new access token'))

    stub_oauth2_client
    stub_store
    @manager = AccessTokenManager.new(@oauth2_client ,@store, anything)
  end

  describe "Returning a new access token from the server" do

    before(:each) do
      allow(@oauth2_client).to receive(:request_new_access_token){@access_token_instance}
    end

    it 'Returns a string token, which is returned by the oauth2 client' do
      expect(@manager.request_new_token('authorization code')).to eq 'new access token'
    end

    it 'Stores the token details after it is returned by the oauth2 client' do
      @manager.request_new_token('authorization code')

      expect(@store).to have_received(:save_credentials_in_file).with(@access_token_instance.to_hash, anything)
    end
  end

  describe "Return an access token from storage" do

    it "Returns a string token when it is found by AuthenticationStore" do
      expect(@manager.get_access_token).to eq "access token in stored in a file"
    end

    it "Returns nil when file is not found by AuthenticationStore" do
      allow(@store).to receive(:load_stored_credentials){nil}

      expect(@manager.get_access_token).to be_nil
    end

    it "Returns a refreshed access token string, when authentication file is found, but the access token has expired" do
       @stored_token_hash.update(:expires_at => (Time.now - 3600).to_s)
      allow(@oauth2_client).to receive(:refresh_access_token){@access_token_instance}

      expect(@manager.get_access_token).to eq 'new access token'
    end

    it "Calls store manager to store the new refresh token when it is received" do
      @stored_token_hash.update(:expires_at => (Time.now - 3600).to_s)
      allow(@oauth2_client).to receive(:refresh_access_token){@access_token_instance}

      @manager.get_access_token

      expect(@store).to have_received(:save_credentials_in_file).with(@access_token_instance.to_hash, anything)
    end

    it "Returns nil when the user_email in file is different from one in oauth2_client" do
      allow(@oauth2_client).to receive(:user_email){'different user_email from the settings'}

      expect(@manager.get_access_token).to be_nil
    end
  end
end