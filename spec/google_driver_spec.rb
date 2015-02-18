require 'rspec'
require 'google/api_client'

require_relative '../spec/spec_helper'
require_relative '../lib/admix/google_drive_client_manager'

include GoogleDriveApiHelper
RSpec.describe AuthenticationManagerForInstalledAppClient do

  before(:all) do
    @client_id ="157478480211-fqa6jd2lucmssqcjvpra07ih39u93etu.apps.googleusercontent.com"
    @client_secret = "oSAoSvc0dxg4H-VTI3OBXLyV"
    @user_email = "mbinsabb@thoughtworks.com"
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
      @number_of_prompt_calls = 3
      @promption_message = "\n2. Enter the authorization code shown in the page: "
      allow_any_instance_of(AuthenticationManagerForInstalledAppClient).to receive(:gets).and_return("rroororrrororor")
      allow_any_instance_of(AuthenticationManagerForInstalledAppClient).to receive(:print)
    end

    it "prompts user when file is not found" do
      manager = AuthenticationManagerForInstalledAppClient.new(@client_id, @client_secret,
                                                               'does_not_exist.json', @user_email)
      manager.access_token

      expect(manager).to(have_received(:gets).exactly(@number_of_prompt_calls))
      expect(manager).to(have_received(:print).with(@promption_message).exactly(@number_of_prompt_calls))
    end

    it "prompts user when user_email in the file is different from the given user_email" do
      file = File.expand_path("../assets/auth_data.json", __FILE__)
      create_file(file)
      manager = AuthenticationManagerForInstalledAppClient.new(@client_id, @client_secret,
                                                               file, "newusername@gmail.com")

      manager.access_token

      expect(manager).to(have_received(:gets).exactly(@number_of_prompt_calls))
      expect(manager).to(have_received(:print).with(@promption_message).exactly(@number_of_prompt_calls))
    end

    it "prompts user when refresh_token is nil" do
      file = File.expand_path("../assets/auth_data.json", __FILE__)
      create_file(file, "random access token", nil)
      manager = AuthenticationManagerForInstalledAppClient.new(@client_id, @client_secret,
                                                               file, @user_email)

      manager.access_token

      expect(manager).to have_received(:gets).exactly(@number_of_prompt_calls)
      expect(manager).to have_received(:print).with(@promption_message).exactly(@number_of_prompt_calls)
    end

    it "prompts user when AuthorizationError is raised (refresh_token is invalid)" do
      file = File.expand_path("../assets/auth_data.json", __FILE__)
      create_file(file, nil, "random refresh token that is invalid")
      manager = AuthenticationManagerForInstalledAppClient.new(@client_id, @client_secret, file,
                                                               @user_email)

      manager.access_token

      expect(manager).to have_received(:gets).exactly(@number_of_prompt_calls)
      expect(manager).to have_received(:print).with(@promption_message).exactly(@number_of_prompt_calls)
    end
  end

  describe "Return an access token" do

    it "returns an access token when it is found and has not expired" do
      file = File.expand_path("../assets/auth_data.json", __FILE__)
      create_file(file, "ya29.HAGs3ezBdmXFRcoceYVoKhQ0aLnh27Mo6OJVaxyiidtYtOr9yCzGapY60CUWT72")
      manager = AuthenticationManagerForInstalledAppClient.new(@client_id, @client_secret, file,@user_email)

      expect(manager.access_token).to eq "ya29.HAGs3ezBdmXFRcoceYVoKhQ0aLnh27Mo6OJVaxyiidtYtOr9yCzGapY60CUWT72"
    end

    it "generates a new access token and returns it when current token has expired" do
      file = File.expand_path("../assets/auth_data_expired.json", __FILE__)
      create_file(file, nil, "1/bJHUo7RGfoXXgLli5XG9ytnWZUmN0DzM2aJOw_aeVFM", "2015-02-15 09:23:22 +0000")
      manager = AuthenticationManagerForInstalledAppClient.new(@client_id, @client_secret, file, @user_email)

      expect(manager.access_token).to_not be_nil
    end
  end
end

RSpec.describe GoogleDriveServiceAccountClient do

  before(:all) do
    @wrapper = GoogleDriveServiceAccountClient.new("app_name", "app_version")
  end

  describe "Authenticate client" do
    it "authenticate the service client, if no email is given" do
      expect(@wrapper.perform_authentication).to eq true
    end

    it "returns false when trying to generate token for a user, if the user has not authorized the client" do
      expect(@wrapper.perform_authentication "fake@email.com").to eq false
    end

    it "returns true when user_email has given authorization to the service account" do
      user_email = 'mbinsabb@thoughtworks.com'
      expect(@wrapper.perform_authentication user_email).to eq true
    end
  end

  describe "Dealing with Files" do
    before(:all) do
      @wrapper.perform_authentication
    end

    it "returns a list of all files, which includes \"How to get started with Drive\", at the account service drive" do
      files = @wrapper.list_all_files_for_the_service_account

      expect(files.find {|file| file.title == 'How to get started with Drive'}).to_not be_nil
    end

    it "downloads \"How to get started with Drive\" PDF file given its file ID" do
      files = @wrapper.list_all_files_for_the_service_account
      file = files.find {|file| file.title == 'How to get started with Drive'}

      expect(@wrapper.download_file file).to_not be_nil
    end

    it "Updates an existing file" do
      files = @wrapper.list_all_files_for_the_service_account
      file = files.find {|file| file.title == 'How to get started with Drive'}
      path_to_file = File.expand_path("../assets/How to get started with Drive.pdf",__FILE__)

      result = @wrapper.update_file(file.id, file.title, 'application/pdf', path_to_file)

      expect(result).to be_a Google::APIClient::Schema::Drive::V2::File
    end

    it "Returns nil when trying to update a drive file that does not exist" do
      path_to_file = File.expand_path("../assets/How to get started with Drive.pdf",__FILE__)

      result = @wrapper.update_file("10827363", "How to get started with Drive", 'application/pdf', path_to_file)

      expect(result).to be_nil
    end

    it "Returns nil when trying to update a drive file with a file that does not exist locally" do
      path_to_file = File.expand_path("../assets/I do not exist.pdf",__FILE__)

      result = @wrapper.update_file("10827363", "How to get started with Drive", 'application/pdf', path_to_file)

      expect(result).to be_nil
    end
  end
end