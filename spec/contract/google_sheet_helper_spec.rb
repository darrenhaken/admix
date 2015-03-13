require 'rspec'
require 'google_drive'

require_relative '../admix/spec_helper'
require_relative '../../lib/admix/google_drive/google_sheet_helper'
require_relative '../../lib/admix/google_drive/google_controller'
require_relative '../../lib/admix/google_drive/google_client_settings'

RSpec.describe GoogleSheetHelper do

  def generate_auth_file
    file = File.expand_path('../../assets/DO_NOT_OPEN_OR_CHANGE_ME.json', __FILE__)
    token_hash = {:access_token => nil,
                  :refresh_token => ENV['GOOGLE_REFRESH_TOKEN'],
                  :expires_in => 3600,
                  :expires_at => (Time.now - (7200)).to_s,
                  :user_email => ENV['GOOGLE_EMAIL']
    }

    File.open(file, 'w+') do |f|
      f.write(JSON.pretty_generate(token_hash))
    end
    file
  end

  before(:all) do
    @client_id =  ENV['GOOGLE_CLIENT_ID']
    @client_secret = ENV['GOOGLE_CLIENT_SECRET']
    @user_email = ENV['GOOGLE_EMAIL']

    @file = generate_auth_file

    settings = GoogleClientSettings.new(@client_id, @client_secret, @user_email)
    controller = GoogleController.new(settings, @file)
    controller.setup_controller
    @access_token = controller.access_token
    @spreadsheet_helper = GoogleSheetHelper.new(@access_token, 'Admix', 'CDF Test')
  end

  after(:all) do
    File.delete(@file)
  end

  it 'Writes an input to a google sheet using the given mapping' do
    @spreadsheet_helper = GoogleSheetHelper.new(@access_token, 'Admix', 'integration test')
    data = {
        :a  => 'This is a',
        :b => 'This is b',
        :c => 'This is c'
    }
    mapping = {
        :a => 1,
        :b => 2,
        :c => 3
    }

    @spreadsheet_helper.write_data_to_worksheet_with_mapping(data, mapping)

    expect(@spreadsheet_helper.get_data_for_last_row_and_column(1)). to eq data[:a]
    expect(@spreadsheet_helper.get_data_for_last_row_and_column(2)). to eq data[:b]
    expect(@spreadsheet_helper.get_data_for_last_row_and_column(3)). to eq data[:c]
  end

end