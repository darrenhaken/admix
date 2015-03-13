require 'rspec'
require 'rest_client'

require_relative '../../lib/admix/mingle/mingle_controller'
require_relative '../../lib/admix/mingle/mingle_settings'
require_relative '../../lib/admix/settings'
require_relative '../../lib/admix/mingle/card_status'

describe MingleController do

  def mock_rest_client(body)
    response = instance_double(RestClient::Response, :code => 200, :body => body)
    allow(RestClient).to receive(:get).and_return(response)
  end

  before(:each) do
    body = File.expand_path('../../assets/xml/mingle_wall_snapshot_with_five_cards.xml', __FILE__)
    mock_rest_client File.read(body)
    mingle_settings = MingleSettings.new('user', 'password', 'url', 'project_name')
    @filter_file = File.expand_path('../../assets/yaml/filter_for_single_typ_and_status.yaml', __FILE__)
    @controller = MingleController.new(mingle_settings, @filter_file)
  end

  it 'returns Hash representing card statistics for commultive flow digram' do
    result = @controller.get_cards_statistics

    expect(result).to be_a Hash
  end

  it 'returns cards statistics returned from the RestClient' do
    _Next = 3
    _QA = 1
    _Dev = 1
    _Dev_done = 2

    result = @controller.get_cards_statistics

    expect(result.delete(CardStatus.QA)).to eq _QA
    expect(result.delete(CardStatus.NEXT)).to eq _Next
    expect(result.delete(CardStatus.NEXT)).to eq _Dev
    expect(result.delete(CardStatus.DEV_DONE)).to eq _Dev_done
    result.each do |k, v|
      expect(v).to eq 0
    end
  end

  it 'returns 0s for card statistics if no cards is returned by RestClient' do
    mock_rest_client ''
    result = @controller.get_cards_statistics

    result.each do |k, v|
      expect(v).to eq 0
    end
  end

  it 'raises MingleControllerError when MingleResourceLoader raises MingleAuthenticationError' do
    response = instance_double(RestClient::Response, :code => 401, :body => nil)
    allow(RestClient).to receive(:get).and_return(response)

    expect{@controller.get_cards_statistics}.to raise_error(MingleControllerError)
  end

  it 'returns nil when MingleResourceLoader fails to load resources' do
    response = instance_double(RestClient::Response, :code => 400, :body => nil)
    allow(RestClient).to receive(:get).and_return(response)

    expect(@controller.get_cards_statistics).to be_nil
  end

  #TODO if MQL filter cannot be parsed ?
end