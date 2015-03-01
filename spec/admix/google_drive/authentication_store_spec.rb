require 'rspec'
require 'json'

require_relative '../../../lib/admix/google_drive/authentication_store'

RSpec.describe AuthenticationStore do

  before(:all) do
    @store = AuthenticationStore.instance
    @path_to_assets = "../../../assets/"
    @auth_json_file = File.expand_path(@path_to_assets + 'auth_data.json', __FILE__)
    @token_hash = {:access_token => 'access_token',
                   :refresh_token => 'refresh_token',
                   :expires_in => 3600,
                   :expires_at => 'expires_at',
                   :user_email => 'user_email'
    }
  end

  def mock_auth_credentials
    auth_credentials = double("Signet::OAuth2::Client")
    allow(auth_credentials).to receive(:access_token){@token_hash[:access_token]}
    allow(auth_credentials).to receive(:refresh_token){@token_hash[:refresh_token]}
    allow(auth_credentials).to receive(:expires_in){@token_hash[:expires_in]}
    allow(auth_credentials).to receive(:expires_at){@token_hash[:expires_at]}
    allow(auth_credentials).to receive(:username){@token_hash[:user_email]}
    auth_credentials
  end

  def create_file(file)
    File.open(file, 'w+') do |f|
      f.write(JSON.pretty_generate(@token_hash))
    end
  end

  it 'return a none-empty Hash object when the file is found' do
    create_file(@auth_json_file)

    result = @store.load_stored_credentials(@auth_json_file)

    expect(result).to be_a Hash and expect(result.empty?).to be false
  end

  it 'contains authentication keys in the returned Hash object' do
    create_file(@auth_json_file)

    result = @store.load_stored_credentials(@auth_json_file)

    expect(result.keys).to contain_exactly(:access_token, :refresh_token, :expires_in, :expires_at, :user_email)
  end

  it 'contains authentication details found in the file in the returned Hash object' do
    create_file(@auth_json_file)

    result = @store.load_stored_credentials(@auth_json_file)

    expect(result[:access_token]).to eq @token_hash[:access_token]
    expect(result[:refresh_token]).to eq @token_hash[:refresh_token]
    expect(result[:expires_in]).to eq @token_hash[:expires_in]
    expect(result[:expires_at]).to eq @token_hash[:expires_at]
    expect(result[:user_email]).to eq @token_hash[:user_email]
  end

  it 'returns nil when file is not found' do
    result = @store.load_stored_credentials("auth_json_file")

    expect(result).to be_nil
  end

  it 'stores authorization credentials in a file and return true' do
    auth_credentials = mock_auth_credentials
    File.open(@auth_json_file, 'w+'){
      #delete file content
    }

    result = @store.save_credentials_in_file(auth_credentials, @auth_json_file)

    expect(result).to be true
  end

  it 'writes the authorization credentials in file in a JSON format' do
    File.open(@auth_json_file, 'w+'){}
    auth_credentials = mock_auth_credentials

    @store.save_credentials_in_file(auth_credentials, @auth_json_file)
    json_data  = JSON.parse(File.read(@auth_json_file))
    stored_data = Hash[json_data.map{|(k,v)| [k.to_sym,v]}]
    
    expect(stored_data).to eq @token_hash
  end
end