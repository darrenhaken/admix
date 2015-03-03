require 'rspec'
require 'google_drive'

require_relative '../admix/spec_helper'
require_relative '../../lib/admix/google_drive/google_sheet_helper'
require_relative '../../lib/admix/google_drive/google_controller'
require_relative '../../lib/admix/google_drive/google_client_settings'

RSpec.describe GoogleSheetHelper do

  #TODO find a way to pass these details via ENV, then revoke acceess, then regrant it again
  before(:all) do
    @client_id =  ENV['GOOGLE_CLIENT_ID']
    @client_secret = ENV['GOOGLE_CLIENT_SECRET']
    @user_email = ENV['GOOGLE_EMAIL']

    file = File.expand_path('../../assets/DO_NOT_OPEN_OR_CHANGE_ME.json', __FILE__)
    token_hash = {:access_token => nil,
                  :refresh_token => ENV['GOOGLE_REFRESH_TOKEN'],
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