require 'rspec'
require 'rest_client'

require_relative '../../lib/admix/cumulative_flow_diagram_logic/mingle_cfd_data_point_loader'
require_relative '../../lib/admix/mingle/mingle_settings'
require_relative '../../lib/admix/utils/settings'
require_relative '../../lib/admix/mingle/card_status'

RSpec.describe MingleCfdDataPointLoader do

  def mock_rest_client(body)
    mingle_wall_cards_response = instance_double(RestClient::Response, :code => 200, :body => body)

    number_of_live_cards_XML = File.read(File.expand_path('../../assets/xml/number_of_card_response.xml', __FILE__))
    number_of_live_cards_response = instance_double(RestClient::Response, :code => 200, :body => number_of_live_cards_XML)

    allow(RestClient).to receive(:get).with(anything, anything) do |_, params|
      param = params[:params]
      param[:mql].include?('SELECT COUNT(*) WHERE')? number_of_live_cards_response:mingle_wall_cards_response
    end
  end

  before(:each) do
    body = File.expand_path('../../assets/xml/mingle_wall_snapshot_with_five_cards.xml', __FILE__)
    mock_rest_client(File.read(body))
    mingle_settings = MingleSettings.new('user', 'password', 'url', 'project_name', 'start_date')
    @filter_file = File.expand_path('../../assets/yaml/filter_for_single_typ_and_status.yaml', __FILE__)
    @cfd_data_loader = MingleCfdDataPointLoader.new(mingle_settings, @filter_file)
  end

  it 'returns Hash that contains mingle wall card statistics' do
    result = @cfd_data_loader.get_today_cfd_data_point

    expect(result).to be_a Hash
  end

  it 'returns cards statistics returned from the Mingle API' do
    _Next = 3
    _QA = 1
    _Dev = 1
    _Dev_done = 2
    _LIVE = 83

    result = @cfd_data_loader.get_today_cfd_data_point

    expect(result.delete(CardStatus.QA)).to eq _QA
    expect(result.delete(CardStatus.NEXT)).to eq _Next
    expect(result.delete(CardStatus.DEV)).to eq _Dev
    expect(result.delete(CardStatus.DEV_DONE)).to eq _Dev_done
    expect(result.delete(CardStatus.LIVE)).to eq _LIVE
    result.each do |_, v|
      expect(v).to eq 0
    end
  end

  it 'returns 0s for card statistics if no cards is returned from Mingle API' do
    mock_rest_client('')
    result = @cfd_data_loader.get_today_cfd_data_point
    _LIVE = 83

    result.each do |k, v|
      if k == CardStatus.LIVE
        expect(v).to eq _LIVE
      else
        expect(v).to eq 0
        end
    end
  end

  it 'returns nil when MingleResourceLoader fails to load resources' do
    response = instance_double(RestClient::Response, :code => 400, :body => nil)
    allow(RestClient).to receive(:get).and_return(response)

    expect(@cfd_data_loader.get_today_cfd_data_point).to be_nil
  end

  it "shows a user-friendly error message, and exits when MingleAuthenticationError is raised" do
    allow_any_instance_of(MingleResourceLoader).to receive(:get).and_raise(MingleAuthenticationError, "error")

    expect(@cfd_data_loader).to receive(:print).with("\nIncorrect Mingle username/password. Please Update the mingle settings in admix setting file\n")

    expect{@cfd_data_loader.get_today_cfd_data_point}.to raise_error(SystemExit)
  end

end