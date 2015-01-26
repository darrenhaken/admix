require 'rspec'
require 'rest-client'
require 'nokogiri'
require 'date'
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

  RSpec.describe MingleWallSnapshot do

	let(:mingle_stories_xml) {File.read('./assets/mingle_story_response.xml')}

	subject(:mingle_story_wall_snapshot) {MingleWallSnapshot.new(mingle_stories_xml)}

    describe 'MingleWallSnapshot' do
      
      it 'should return number of cards with a status of \'New Customer Request\'' do
      	expect(mingle_story_wall_snapshot.number_of_cards_with_status("New Customer Request")).to eq 1
      end

      it 'should return the number of cards that have gone live in the last 24 hours' do
        expect(mingle_story_wall_snapshot.number_of_cards_that_went_live_since(Date.parse('2015-01-13'), "Done (Deployed to Live)")).to eq 1
      end

      it 'should return that no stories have gone live in the last 24 hours' do
     	expect(mingle_story_wall_snapshot.number_of_cards_that_went_live_since(Date.parse('2015-01-14'), "Done (Deployed to Live)")).to eq 0
      end
    end
  end

end