require 'rspec'

require_relative '../spec_helper'
require_relative '../../lib/admix/google_drive/google_client_settings'
require_relative '../../lib/admix/google_drive/google_worksheet_wrapper'
require_relative '../../lib/admix/google_drive/access_token_file_store'
require_relative '../../lib/admix/cumulative_flow_diagram_logic/mingle_cfd_data_point'
require_relative '../../lib/admix/cumulative_flow_diagram_logic/cfd_filler_for_worksheet'
require_relative '../../lib/admix/cumulative_flow_diagram_logic/cfd_data_point_to_column_mapper'

RSpec.describe CfdFillerForWorksheet do

  def setup_google_settings
    @spreadsheet_title = 'Admix'
    @worksheet_title = 'CDF Test'
    @settings = GoogleClientSettings.new(ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET'],
                                         ENV['GOOGLE_EMAIL'], @spreadsheet_title, @worksheet_title)
  end

  def check_inserted_data
    token_hash = @store.load_stored_access_token(@auth_json_file)
    wrapper = GoogleWorksheetWrapper.new(token_hash[:access_token])
    wrapper.get_worksheet_in_spreadsheet(@worksheet_title, @spreadsheet_title)
    assert_data(wrapper)
  end

  def assert_data(wrapper)
    mappings = CfdDataPointToColumnMapper.mapping
    @cfd_data_point.each do |k, v|
      expect(wrapper.value_in_the_last_row_for_column(mappings[k])).to eq "#{v}"
    end
  end

  before(:all) do
    @auth_json_file = generate_auth_file
    @store = AccessTokenFileStore.instance

    setup_google_settings

    @cfd_data_point ={
        'Done (Deployed to Live)' => 90, 'QA' => 1, 'QA done' => 3, 'Dev' => 3,
        'Dev done' => 2, 'A & D' => 1, 'A & D done' => 2, 'Next' => 5
    }
  end

  it 'insert a cfd data point to a row in a google worksheeet' do
    data_filler = CfdFillerForWorksheet.new(@settings, @auth_json_file)

    data_filler.insert_cfd_data_point_for_date(@cfd_data_point, Time.now)
    data_filler.commit_changes

    check_inserted_data
  end

end