require 'rspec'
require 'rest_client'

require_relative '../../../../lib/admix/mingle/mingle_resource_loader'

RSpec.describe MingleResourceLoader do

  before(:all) do
    @username = 'fakeusernmae'
    @password = 'fakepassword'
    @mingle_url = 'tw-digital.mingle.thoughtworks.com'
    @path_to_assets = "../../../../assets/xml/"
    @loader = MingleResourceLoader.new(@username, @password, @mingle_url, RestClient)
  end

  describe 'Initialising MingleResourceLoader' do
    it 'formats the Mingle API rest resource URL given the name of the project' do
      expected_format = 'https://'+@username+':'+@password+'@'+@mingle_url+'/api/v2/projects/tw_dot_com/cards/execute_mql.xml'

      expect(@loader.full_rest_resource('tw_dot_com')).to eq expected_format
    end
  end

  describe 'Loads resource from Mingle' do

    before(:all) do
      @mql = 'SELECT * WHERE Type = Defect'
      @params = {:params => {:mql => @mql}}
    end

    before(:each) do
      @rest_client = object_double("RestClient")
      @project_url = @loader.full_rest_resource('project')
      @loader = MingleResourceLoader.new(@username, @password, @mingle_url, @rest_client)
    end

    def make_response(**args)
      body = args.has_key?(:body)? args[:body]:"Response Body"
      instance_double(RestClient::Response, :code => args[:code], :body => body)
    end

    it 'returns  XML data when getting cards and the returned status code is 200' do
      xml_file = File.expand_path(@path_to_assets+'mingle_story_response.xml', __FILE__)
      response_body = File.read(xml_file)
      allow(@rest_client).to receive(:get) {make_response(:code => 200, :body => response_body)}

      get_result = @loader.get('project', @mql)

      expect(get_result).to be response_body
    end

    it 'returns false when getting cards and the returned status code not in range 2XX'do
      allow(@rest_client).to receive(:get) {make_response(:code => 400)}

      get_result = @loader.get('project', @mql)

      expect(get_result).to be nil
    end

    it "throws MingleAPIAuthorisationError when status code is 401 " do
      allow(@rest_client).to receive(:get).and_raise(RestClient::Unauthorized, "Unauthorized Access")

      expect {@loader.get('project', @mql)}.to raise_error(MingleAuthenticationError)
    end

    it "calls get with the project_url and sets 'mql' parameter from mql filter" do
      allow(@rest_client).to receive(:get) {make_response(:code => 200)}

      @loader.get('project', @mql)

      expect(@rest_client).to have_received(:get).with(@project_url, @params).once
    end
  end
end