require 'rspec'
require 'google/api_client'
require 'json'

require_relative '../../lib/admix/google_drive/access_token_manager'
require_relative '../../lib/admix/google_drive/google_client_settings'
require_relative '../../lib/admix/google_drive/access_token_file_store'
require_relative '../../lib/admix/google_drive/google_drive_o_auth2_client'

def setup_oauth2_client
  @google_auth_client = (Google::APIClient.new(:application_name => 'Admix', :application_version => '1')).authorization
  @client_settings = GoogleClientSettings.new('google_client_id@googledev.com', 'notrealclientsecret124',
                                              'randomemail@example.com', 'title', 'ws_title')
  @oauth2_client = GoogleDriveOAuth2Client.new(@google_auth_client, @client_settings)
end

def generate_auth_file_with_time(time)
  File.open(@existing_auth_file, 'w+') do |f|
    f.write(JSON.pretty_generate(@expected_file_content.update('access_token' => 'a refreshed access token',
                                                               'expires_at'=> time.to_s)))
  end
end

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

    @expected_file_content = @generated_token_response
    @expected_file_content.update('user_email'=>'randomemail@example.com')

    setup_oauth2_client
    @store = AccessTokenFileStore.instance()
  end

  after(:all) do
    File.delete(@new_auth_file)
    File.delete(@existing_auth_file)
  end

  describe 'Authentication credentials are stored/loaded in/from a json file' do

    def assert_file_content(file1, expected, assert_refresh_token=true)
      if assert_refresh_token
        expect(file1['refresh_token']).to eq expected['refresh_token']
      end
      expect(file1['access_token']).to eq expected['access_token']
      expect(file1['expires_at']).to eq expected['expires_at']
      expect(file1['expired_in']).to eq expected['expired_in']
      expect(file1['user_email']).to eq expected['user_email']
    end

    it "Stores authentication credentials, when it is returned by the server" do
      @manager = AccessTokenManager.new(@oauth2_client, @store, @new_auth_file)
      allow(@google_auth_client).to receive(:fetch_access_token){@generated_token_response}
      @expected_file_content.update('expires_at' => (Time.now + 3600).to_s)

      @manager.request_new_token('an authorization code')

      generated_file_content = JSON.parse(File.read(@new_auth_file))
      assert_file_content(generated_file_content, @expected_file_content)
    end

    it "Updates access_token in json file when an access token is refreshed" do
      generate_auth_file_with_time(Time.now - 3600)
      @manager = AccessTokenManager.new(@oauth2_client, @store, @existing_auth_file)
      allow(@google_auth_client).to receive(:fetch_access_token){@refresh_token_response}
      @expected_file_content.update('expires_at' => (Time.now + 3600).to_s)

      @manager.get_access_token

      updated_file_content = JSON.parse(File.read(@existing_auth_file))
      assert_file_content(updated_file_content, @expected_file_content)
    end

    it 'Loads the access token from the auth file and return its token string' do
      generate_auth_file_with_time(Time.now + 3600)
      @manager = AccessTokenManager.new(@oauth2_client, @store, @existing_auth_file)

      expect(@manager.get_access_token).to eq @expected_file_content['access_token']
    end
  end

end