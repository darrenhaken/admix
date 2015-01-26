require 'rspec'
require 'rest-client'
require 'nokogiri'
require_relative '../spec/spec_helper'
require_relative '../lib/admix/mingle'

module Admix

  RSpec.describe MingleResource do

  	let(:response) {instance_double(RestClient::Response, :code => 200, :body => "successful get request")}
  	let(:rest_resource) {instance_double(RestClient::Resource, :get => response)}
  	subject {Admix::MingleResource.new(rest_resource)}

    describe 'get_cards' do
      it 'returns response body' do
      	expect(subject.get_cards).to eq "successful get request"
      end

      it 'raises an exception when the status code is not 200' do
        allow(response).to receive(:code).and_return(404)
        expect(subject.get_cards).to eq "should this raise an exception?"
      end
    end
  end

  RSpec.describe XMLTransformation do

	let(:mingle_stories_xml) {File.read('./assets/mingle_story_response.xml')}

	subject(:xml_transformer) {XMLTransformation.new(mingle_stories_xml)}

    describe 'xml_transformation' do
      it 'should marshall xml to objects' do
      	expect(xml_transformer.number_of_tag_occurences("card")).to eq 2
      end

      it 'should return number of stories gone live in the last 24 hours' do
      	expect(xml_transformer.number_of_stories_gone_live_since(nil)).to eq 1
      end
    end
  end

end