require 'rspec'
require 'google/api_client'
require 'json'

require_relative '../../lib/admix/google_drive/access_token_manager'
require_relative '../../lib/admix/google_drive/google_client_settings'
require_relative '../../lib/admix/google_drive/authentication_store'

RSpec.describe AccessTokenManager do

  before(:all) do
    @new_auth_file = File.expand_path('../../assets/new_auth_file.json', __FILE__)
    @existing_auth_file = File.expand_path('../../assets/existing_auth_file.json', __FILE__)

    @generated_token_response = {
        'refresh_token' => 'a refresh token',
        'access_token' => 'a newly generated access token',
        'expires_in' => 3600,
    }
    @refresh_token_response = {
        'access_token' => 'a refreshed access token',
        'expires_in' => 3600,
    }
    @expected_file_content = @generated_token_response.update('user_email'=>'randomemail@example.com')
  end

  after(:all) do
    File.delete(@new_auth_file)
    File.delete(@existing_auth_file)
  end

  before(:each) do
    @client_auth = (Google::APIClient.new(:application_name=>'Admix', :application_version=>'1')).authorization
    @client_settings = GoogleClientSettings.new('google_client_id@googledev.com', 'notrealclientsecret124',
                                                'randomemail@example.com', 'title', 'ws_title')
    @store = AuthenticationStore.instance()
  end

  def generate_auth_file_with_time(time)
    File.open(@existing_auth_file, 'w+') do |f|
      f.write(JSON.pretty_generate(@expected_file_content.update('access_token' => 'a refreshed access token',
                                                                 'expires_at'=> time.to_s)))
    end
  end

  describe 'Authentication credentials are stored/loaded in/from a json file' do

    def assert_file_content(file1, expected)
      expect(file1['refresh_token']).to eq expected['refresh_token']
      expect(file1['access_token']).to eq expected['access_token']
      expect(file1['expires_at']).to eq expected['expires_at']
      expect(file1['expired_in']).to eq expected['expired_in']
      expect(file1['user_email']).to eq expected['user_email']
    end

    it "stores authentication credentials when it is returned by the server" do
      @manager = AccessTokenManager.new(@client_auth, @client_settings, @store, @new_auth_file)
      allow(@client_auth).to receive(:fetch_access_token){@generated_token_response}
      @expected_file_content = @expected_file_content.update('expires_at' => (Time.now + 3600).to_s)

      @manager.request_new_token('an authorization code')

      generated_file_content = JSON.parse(File.read(@new_auth_file))
      assert_file_content(generated_file_content, @expected_file_content)
    end

    it "Update access_token in json file when an access token is refreshed" do
      generate_auth_file_with_time(Time.now - 3600)
      @manager = AccessTokenManager.new(@client_auth, @client_settings, @store, @existing_auth_file)
      allow(@client_auth).to receive(:fetch_access_token){@refresh_token_response}
      @expected_file_content = @expected_file_content.update('expires_at' => (Time.now + 3600).to_s)

      @manager.get_access_token

      updated_file_content = JSON.parse(File.read(@existing_auth_file))
      assert_file_content(updated_file_content, @expected_file_content)
    end

    it 'loads the access token from the file and return it' do
      generate_auth_file_with_time(Time.now + 3600)
      @manager = AccessTokenManager.new(@client_auth, @client_settings, @store, @existing_auth_file)

      expect(@manager.get_access_token).to eq @expected_file_content['access_token']
    end
  end

  describe "Sets the correct params for authentication requests" do
    it "sets grant_type to nil, and code for requesting new token" do
      @manager = AccessTokenManager.new(@client_auth, @client_settings, @store, @new_auth_file)
      allow(@client_auth).to receive(:fetch_access_token){@generated_token_response}

      expect(@client_auth).to receive(:grant_type=).with(nil)
      expect(@client_auth).to receive(:code=).with('an authorization code')

      @manager.request_new_token('an authorization code')
    end

    it "sets grant_type to 'refresh_token', and refresh_token for file value for requesting new token" do
      generate_auth_file_with_time(Time.now - 3600)
      @manager = AccessTokenManager.new(@client_auth, @client_settings, @store, @existing_auth_file)
      allow(@client_auth).to receive(:fetch_access_token){@generated_token_response}

      expect(@client_auth).to receive(:grant_type=).with('refresh_token')
      expect(@client_auth).to receive(:refresh_token=).with(@expected_file_content['refresh_token'])

      @manager.get_access_token
    end
  end

end