require 'rspec'
require 'rest_client'

require_relative '../../../lib/admix/mingle/mingle_api_wrapper'

RSpec.describe MingleAPIWrapper do

  before(:all) do
    @username = 'mbinsabb'
    @password = 'fakepassword'
    @mingle_url = 'tw-digital.mingle.thoughtworks.com'
    @path_to_assets = "../../../assets/"
    @wrapper = MingleAPIWrapper.new(@username, @password, @mingle_url, RestClient)
  end

  describe 'Initialising MingleAPIWrapper' do

    it 'accepts four params for init MingleAPIWrapper' do
      expect(@wrapper).to_not be_nil
    end

    it 'formats the Mingle API rest resource URL for project cards, given the name of the project' do
      expected_format = 'https://'+@username+':'+@password+'@'+@mingle_url+'/api/v2/projects/tw_dot_com/cards/execute_mql.xml'

      expect(@wrapper.full_rest_resource('tw_dot_com')).to eq expected_format
    end
  end

  describe 'Getting resource from Mingle' do

    before(:all) do
      @mql = 'SELECT * WHERE Type = Defect'
      @params = {:params => {:mql => @mql}}
    end

    before(:each) do
      @rest_client = double("RestClient")
      @project_url = @wrapper.full_rest_resource('project')
    end

    def make_response(**args)
      body = args.has_key?(:body)? args[:body]:"Response Body"
      instance_double(RestClient::Response, :code => args[:code], :body => body)
    end

    it 'returns true when getting cards and the returned status code is 200' do
      allow(@rest_client).to receive(:get) {make_response(:code => 200)}
      wrapper = MingleAPIWrapper.new(@username, @password, @mingle_url, @rest_client)

      get_result = wrapper.get_cards_for_project('project', @mql)

      expect(get_result).to be true
    end

    it 'returns false when getting cards and the returned status code not in range 2XX'do
      allow(@rest_client).to receive(:get) {make_response(:code => 400)}
      wrapper = MingleAPIWrapper.new(@username, @password, @mingle_url, @rest_client)

      get_result = wrapper.get_cards_for_project('project', @mql)

      expect(get_result).to be false
    end

    it "throws MingleAPIAuthorisationError when status code is 401 " do
      allow(@rest_client).to receive(:get) {make_response(:code => 401)}
      wrapper = MingleAPIWrapper.new(@username, @password, @mingle_url, @rest_client)

      expect {wrapper.get_cards_for_project('project', @mql)}.to raise_error(MingleAPIAuthenticationError)
    end

    it 'returns XML data from "resource" which contains all project cards if status code is 200' do
      xml_file = File.expand_path(@path_to_assets+'mingle_story_response.xml', __FILE__)
      response_body = File.read(xml_file)
      allow(@rest_client).to receive(:get) {make_response(:code => 200, :body => response_body)}
      wrapper = MingleAPIWrapper.new(@username, @password, @mingle_url, @rest_client)

      wrapper.get_cards_for_project('project', @mql)

      expect(wrapper.resource).to be response_body
    end

    it "it calls get with the project_url and sets 'mql' parameter from mql filter" do
      allow(@rest_client).to receive(:get) {make_response(:code => 200)}
      wrapper = MingleAPIWrapper.new(@username, @password, @mingle_url, @rest_client)

      wrapper.get_cards_for_project('project', @mql)

      expect(@rest_client).to have_received(:get).with(@project_url, @params).once
    end
  end
end