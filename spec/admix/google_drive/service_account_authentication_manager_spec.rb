require 'rspec'
require 'google/api_client'
require 'google_drive'

require_relative '../spec_helper'
require_relative '../../../lib/admix/google_drive/service_account_authentication_manager'


RSpec.describe ServiceAccountClientApp::AuthenticationManager do

  before(:all) do
    @wrapper = ServiceAccountClientApp::AuthenticationManager.new("app_name", "app_version")
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
      path_to_file = File.expand_path('../../../assets/How to get started with Drive.pdf',__FILE__)

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