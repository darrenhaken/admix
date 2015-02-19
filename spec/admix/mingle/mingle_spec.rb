require 'rspec'
require 'rest-client'
require 'nokogiri'
require 'date'
require_relative '../../../spec/admix/spec_helper'
require_relative '../../../lib/admix/mingle/mingle'

module Admix

  RSpec.describe MingleWallSnapshot do
    let(:file){File.expand_path('../../../assets/mingle_story_response.xml',__FILE__)}
    let(:mingle_stories_xml) {File.read(file)}

    subject(:mingle_story_wall_snapshot) {MingleWallSnapshot.new(mingle_stories_xml)}

    describe 'MingleWallSnapshot' do
      
      it 'should return number of cards with a status of \'New Customer Request\'' do
      	expect(mingle_story_wall_snapshot.number_of_cards_with_status("New Customer Request")).to eq 1
      end

      it 'should return the number one, indicating that a single card has gone live in the last 24 hours' do
        expect(mingle_story_wall_snapshot.number_of_cards_that_went_live_since(Date.parse('2015-01-13'), "Done (Deployed to Live)")).to eq 1
      end

      it 'should return then number zero, indicating that no stories have gone live in the last 24 hours' do
     	expect(mingle_story_wall_snapshot.number_of_cards_that_went_live_since(Date.parse('2015-01-14'), "Done (Deployed to Live)")).to eq 0
      end
    end
  end

  # RSpec.describe CumulativeFlowDiagramSpreadsheet do
  #
  #   let(:cfd_spreadsheet) {CumulativeFlowDiagramSpreadsheet.new}
  #
  #   describe CumulativeFlowDiagramSpreadsheet do
  #
  #     it 'should authenticate with Google Drive' do
  #       client = cfd_spreadsheet.build_client 'afahie@thoughtworks.com'
  #       file = cfd_spreadsheet.get_file_metadata client, '0AqgwNq-F1tXfdEtFaEx4T0lmV3FrcmhjcEFBQzhxc1E'
  #       #puts cfd_spreadsheet.download_file client, file
  #     end
  #
  #   end
  # end

end