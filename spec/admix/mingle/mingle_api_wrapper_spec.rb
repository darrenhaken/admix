require 'rspec'
require 'rest_client'

require_relative '../../../lib/admix/mingle/mingle_api_wrapper'

RSpec.describe MingleAPIWrapper do

  before(:all) do
    @username = 'mbinsabb'
    @password = 'fakepassword'
    @mingle_url = 'tw-digital.mingle.thoughtworks.com'
    @path_to_assets = "../../../assets/"
  end

  before(:each) do
    @wrapper = MingleAPIWrapper.new(@username, @password, @mingle_url, RestClient)
  end

  describe 'Initialising MingleAPIWrapper' do

    it 'accepts four params for init MingleAPIWrapper' do
      expect(@wrapper).to_not be_nil
    end

    it 'formats the Mingle API rest resource URL with the given username, password, and mingle_url' do
      expected_format = 'https://'+@username+':'+@password+'@'+@mingle_url+'/api/v2/projects.xml'

      expect(@wrapper.full_rest_resource).to eq expected_format
    end

    it 'formats the Mingle API rest resource URL for project cards, given the name of the project' do
      expected_format = 'https://'+@username+':'+@password+'@'+@mingle_url+'/api/v2/projects/tw_dot_com/cards.xml'

      expect(@wrapper.full_rest_resource('tw_dot_com')).to eq expected_format
    end
  end

  describe 'Getting resource from Mingle' do

    it 'returns true when loading a card returns a 200 status code' do
      rest_client = double("RestClient")
      response = instance_double(RestClient::Response, :code => 200, :body => 'successful get request')
      allow(rest_client). to receive(:get) {response}
      wrapper = MingleAPIWrapper.new(@username, @password, @mingle_url, rest_client)
      project_url = wrapper.full_rest_resource('project')

      expect(wrapper.get_cards_for_project('project')).to be true
      expect(rest_client).to have_received(:get).with(project_url).once
    end

    it 'returns false when loading a card returns status code not in range 2XX'do
      rest_client = double("RestClient")
      response = instance_double(RestClient::Response, :code => 400, :body => 'body')
      allow(rest_client). to receive(:get) {response}
      wrapper = MingleAPIWrapper.new(@username, @password, @mingle_url, rest_client)
      project_url = wrapper.full_rest_resource('project')

      expect(wrapper.get_cards_for_project('project')).to be false
      expect(rest_client).to have_received(:get).with(project_url).once
    end

    it "throws MingleAPIAuthorisationError when status code is 401 " do
      rest_client = double("RestClient")
      response = instance_double(RestClient::Response, :code => 401, :body => 'body')
      allow(rest_client). to receive(:get) {response}
      wrapper = MingleAPIWrapper.new(@username, @password, @mingle_url, rest_client)

      expect {wrapper.get_cards_for_project('project')}.to raise_error(MingleAPIAuthenticationError)
    end

    it 'returns XML data which contains all project cards' do
      xml_file = File.expand_path(@path_to_assets+'mingle_story_response.xml', __FILE__)
      response_body = File.read(xml_file)
      rest_client = double("RestClient")
      response = instance_double(RestClient::Response, :code => 200, :body => response_body)
      allow(rest_client). to receive(:get) {response}

      wrapper = MingleAPIWrapper.new(@username, @password, @mingle_url, rest_client)
      wrapper.get_cards_for_project('project')

      expect(wrapper.resource).to be response_body
    end

  end

end