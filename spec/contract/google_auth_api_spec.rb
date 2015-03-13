require 'rspec'
require 'json'

describe 'Contract Test for Google::APIClient' do

  before(:all) do
    @client_id = ENV['GOOGLE_CLIENT_ID']
    @client_secret = ENV['GOOGLE_CLIENT_SECRET']
    @user_email = ENV['GOOGLE_EMAIL']
    @path_to_assets = "../../assets/"
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
    it "Generated a new refresh token and access token when given authorisation code" do

    end

    #TODO this needs a constant refresh token to use for refresing an access token for an account
    it "generates a new access token and returns it when current token has expired" do
      create_file(@auth_json_file, nil, 'a refresh token to use for the request', "2015-02-15 09:23:22 +0000")
    end
  end

end