require 'rspec'
require 'rest-client'
require_relative '../spec/spec_helper'
require_relative '../lib/admix/mingle'

module Admix

  RSpec.describe RestResource do

  	let(:response) {instance_double(RestClient::Response, :code => 200, :body => "successful get request")}
  	let(:rest_resource) {instance_double(RestClient::Resource, :get => response)}
  	subject {Admix::MingleResource.new(rest_resource)}

    describe '#get' do
      it 'returns response body' do
      	expect(subject.get_cards).to eq "successful get request"
      end

      it 'raises an exception when the status code is not 200' do
        allow(response).to receive(:body).and_return(404)
        expect(subject.get_cards).to eq "should this raise an exception?"
      end
    end
  end

end