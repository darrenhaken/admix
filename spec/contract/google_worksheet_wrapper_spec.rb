require 'rspec'
require 'google_drive'

require_relative '../spec_helper'
require_relative '../../lib/admix/google_drive/google_worksheet_wrapper'
require_relative '../../lib/admix/google_drive/google_controller'
require_relative '../../lib/admix/google_drive/google_client_settings'


RSpec.describe GoogleWorksheetWrapper do

  def data_for_row_and_column(row_number, column_number)
    @worksheet[row_number, column_number]
  end

  def last_row_for_worksheet_with_title(worksheet_title)
    @worksheet = @spreadsheet_helper.get_worksheet_in_spreadsheet(worksheet_title, @spreadsheet_title)
    @worksheet.num_rows
  end

  before(:all) do
    @file = generate_auth_file

    settings = GoogleClientSettings.new(ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET'], ENV['GOOGLE_EMAIL'], '', '')
    @spreadsheet_title =  'Admix'
    @worksheet_title =  'CDF Test'
    @integration_test_worksheet = 'integration test'
    controller = GoogleController.new(settings, @file)
    controller.setup_controller
    @spreadsheet_helper = GoogleWorksheetWrapper.new(controller.access_token)
  end

  after(:all) do
    File.delete(@file)
  end

  it 'returns a worksheet given its title and its spreadsheet title' do
    worksheet = @spreadsheet_helper.get_worksheet_in_spreadsheet(@worksheet_title, @spreadsheet_title)

    expect(worksheet.title).to eq @worksheet_title
  end

  it 'returns nil when worksheet is not found' do
    worksheet = @spreadsheet_helper.get_worksheet_in_spreadsheet('does not exist', @spreadsheet_title)

    expect(worksheet).to be_nil
  end

  it 'Writes an input to a google sheet using the given mapping' do
    worksheet = @spreadsheet_helper.get_worksheet_in_spreadsheet(@integration_test_worksheet, @spreadsheet_title)

    data = {
        :a  => 'This is a',
        :b => 'This is b',
        :c => 'This is c',
        :date => Time.now().to_s
    }
    mapping = {
        :date => 1,
        :a => 2,
        :b => 3,
        :c => 4,
    }

    @spreadsheet_helper.write_data_to_last_row_using_mapping(worksheet, data, mapping)
    @spreadsheet_helper.push_changes_to_google_drive

    row_number = last_row_for_worksheet_with_title(worksheet.title)
    expect(data_for_row_and_column(row_number, 1)). to eq data[:date]
    expect(data_for_row_and_column(row_number, 2)). to eq data[:a]
    expect(data_for_row_and_column(row_number, 3)). to eq data[:b]
    expect(data_for_row_and_column(row_number, 4)). to eq data[:c]
    end

  it 'Returns the value for the last row, for the given column' do
    worksheet = @spreadsheet_helper.get_worksheet_in_spreadsheet(@integration_test_worksheet, @spreadsheet_title)
    data = { :first_column => 'a value' }
    mapping = { :first_column => 1 }

    @spreadsheet_helper.write_data_to_last_row_using_mapping(worksheet, data, mapping)

    value = @spreadsheet_helper.value_in_the_last_row_for_column(1)

    expect(value). to eq data[:first_column]
  end

end