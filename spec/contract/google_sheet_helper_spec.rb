require 'rspec'
require 'google_drive'

require_relative '../../../spec/admix/spec_helper'
require_relative '../../../lib/admix/google_drive/google_sheet_helper'
require_relative '../../../lib/admix/google_drive/google_controller'
require_relative '../../../lib/admix/google_drive/google_client_settings'

RSpec.describe GoogleSheetHelper do

  #TODO find a way to pass these details via ENV, then revoke acceess, then regrant it again
  before(:all) do
    @client_id ="157478480211-fqa6jd2lucmssqcjvpra07ih39u93etu.apps.googleusercontent.com"
    @client_secret = "oSAoSvc0dxg4H-VTI3OBXLyV"
    @user_email = "admixmingle@gmail.com"

    file = File.expand_path('../../../assets/DO_NOT_OPEN_OR_CHANGE_ME.json', __FILE__)
    token_hash = {:access_token => "ya29.HQEbxjcfueHfNQxfsWqM4kzlXb0hTS9uA-CZH0IoyYMC8V0Avh98Oq4PmLBQIbCqpg1xMxX8oFzFSg",
                  :refresh_token => "1/RLcvXpydxAQCe_xjklDtrJoaneNnokf8av_J9SQ24pN90RDknAdJa_sgfheVM0XT",
                  :expires_in => 3600,
                  :expires_at => (Time.now - (7200)).to_s,
                  :user_email => @user_email
    }
    File.open(file, 'w+') do |f|
      f.write(JSON.pretty_generate(token_hash))
    end
    settings = GoogleClientSettings.new(@client_id, @client_secret, @user_email)
    controller = GoogleController.new(settings, file)
    controller.setup_controller
    access_token = controller.access_token
    @spreadsheetHelper = GoogleSheetHelper.new(access_token)
  end

  before(:each) do
    # Whenever the authorization fails, just manually generate authorization code and put it here
    # Then open DO_NOT_OPEN_OR_CHANGE_ME.json and copy all the values to token_hash above
    # The instruction is written in SPREADSHEET_README.txt

    authorization_code = "4/WQLOfvgiLEUpOeLfREv0VOC20SD4NLX9qqlAj411puY.cslYlQ-rSXMZoiIBeO6P2m-8BxkxlwI"
    # allow_any_instance_of(AuthenticationManagerForInstalledAppClient).to receive(:gets).and_return(authorization_code)
  end

  describe "Retriving spreedsheet files" do
    it "lists all the spreedsheet files" do
      files = @spreadsheetHelper.list_all_files

      expect(files.length).to eq 1
      expect(files[0]).to be_a GoogleDrive::Spreadsheet
    end

    it "returns a spreadsheet given the title" do
      file = @spreadsheetHelper.get_sheet_with_title("Admix")

      expect(file.title).to eq "Admix"
    end
  end
end