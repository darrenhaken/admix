require 'rspec'
require 'rest-client'
require_relative '../spec/spec_helper'
require_relative '../lib/admix/mingle'

module Admix

  RSpec.describe Mingle do

    let (:rest_client) { instance_double(RestClient) }
    subject { Mingle.new(rest_client, {}) }

    describe '#find_cards' do
      it 'should do something' do

        expect(true).to eq true
      end
    end
  end
end

