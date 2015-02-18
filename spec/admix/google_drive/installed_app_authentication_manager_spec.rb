require 'rspec'
require 'google_drive'

require_relative '../../../spec/admix/spec_helper'
require_relative '../../../lib/admix/google_drive/installed_app_authentication_manager'



RSpec.describe InstalledApplication::AuthenticationManager do

  before(:all) do
    @client_id ="157478480211-fqa6jd2lucmssqcjvpra07ih39u93etu.apps.googleusercontent.com"
    @client_secret = "oSAoSvc0dxg4H-VTI3OBXLyV"
    @user_email = "mbinsabb@thoughtworks.com"
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

  describe "Prompts User for Drive Access Authorization to Client" do

    before(:each) do
      @number_of_prompt_calls = 4
      @promption_message = "\n2. Enter the authorization code shown in the page: "
      allow_any_instance_of(InstalledApplication::AuthenticationManager).to receive(:gets).and_return("random_auth_code")
      allow_any_instance_of(InstalledApplication::AuthenticationManager).to receive(:print)
    end

    it "prompts user when file is not found" do
      manager = InstalledApplication::AuthenticationManager.new(@client_id, @client_secret,
                                                               'does_not_exist.json', @user_email)
      manager.access_token

      expect(manager).to(have_received(:gets).exactly(@number_of_prompt_calls))
      expect(manager).to(have_received(:print).with(@promption_message).exactly(@number_of_prompt_calls))
    end

    it "prompts user when user_email in the file is different from the given user_email" do
      create_file(@auth_json_file)
      manager = InstalledApplication::AuthenticationManager.new(@client_id, @client_secret,
                                          @auth_json_file, "newusername@gmail.com")

      manager.access_token

      expect(manager).to(have_received(:gets).exactly(@number_of_prompt_calls))
      expect(manager).to(have_received(:print).with(@promption_message).exactly(@number_of_prompt_calls))
    end

    it "prompts user when refresh_token is nil" do
      create_file(@auth_json_file, "random access token", nil)
      manager = InstalledApplication::AuthenticationManager.new(@client_id, @client_secret,
                                          @auth_json_file, @user_email)

      manager.access_token

      expect(manager).to have_received(:gets).exactly(@number_of_prompt_calls)
      expect(manager).to have_received(:print).with(@promption_message).exactly(@number_of_prompt_calls)
    end

    it "prompts user when AuthorizationError is raised (refresh_token is invalid)" do
      create_file(@auth_json_file, nil, "random refresh token that is invalid")
      manager = InstalledApplication::AuthenticationManager.new(@client_id, @client_secret,
                                          @auth_json_file, @user_email)

      manager.access_token

      expect(manager).to have_received(:gets).exactly(@number_of_prompt_calls)
      expect(manager).to have_received(:print).with(@promption_message).exactly(@number_of_prompt_calls)
    end
  end

  describe "Return an access token" do

    it "returns an access token when it is found and has not expired" do
      create_file(@auth_json_file, "ya29.HAGs3ezBdmXFRcoceYVoKhQ0aLnh27Mo6OJVaxyiidtYtOr9yCzGapY60CUWT72")
      manager = InstalledApplication::AuthenticationManager.new(@client_id, @client_secret, @auth_json_file,@user_email)

      expect(manager.access_token).to eq "ya29.HAGs3ezBdmXFRcoceYVoKhQ0aLnh27Mo6OJVaxyiidtYtOr9yCzGapY60CUWT72"
    end

    it "generates a new access token and returns it when current token has expired" do
      create_file(@auth_json_file, nil, "1/bJHUo7RGfoXXgLli5XG9ytnWZUmN0DzM2aJOw_aeVFM", "2015-02-15 09:23:22 +0000")
      manager = InstalledApplication::AuthenticationManager.new(@client_id, @client_secret, @auth_json_file, @user_email)

      expect(manager.access_token).to_not be_nil
    end
  end
end