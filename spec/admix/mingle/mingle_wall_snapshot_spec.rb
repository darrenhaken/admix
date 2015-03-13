require 'rspec'

require_relative '../../../spec/admix/spec_helper'
require_relative '../../../lib/admix/mingle/mingle_wall_snapshot'
require_relative '../../../lib/admix/mingle/mingle_card'

RSpec.describe MingleWallSnapshot do

  before(:all) do
    @xml_path = File.expand_path('../../../assets/xml/',__FILE__)
    @xml_file = @xml_path + '/mingle_wall_snapshot_with_five_cards.xml'
    @xml_string = File.read(@xml_file)

    @xml_file = @xml_path + '/number_of_card_response.xml'
    @xml_live_card = File.read(@xml_file)
  end

  describe "Initialises MingleWallSnapshot from an XML string" do
    before(:each) do
      @mingle_wall = MingleWallSnapshot.new(@xml_string, @xml_live_card)
    end

    it "creates MingleWallSnapshot and returns an array of MingleCard objects" do
      expect(@mingle_wall.cards.all? {|card| card.is_a? MingleCard}).to be true
    end

    it "creates MingleWallSnapshot with empty cards array if XML has no cards" do
      @mingle_wall = MingleWallSnapshot.new('', @xml_live_card)

      expect(@mingle_wall.cards).to be_nil
    end

    it "creates MingleWallSnapshot and returns an array of 7 MingleCard objects" do
      expect(@mingle_wall.cards.length).to be 7
    end

    it "creates MingleWallSnapshot and returns an array of 84 as count of live cards" do
      expect(@mingle_wall.number_of_live_cards).to be 83
    end
  end

  describe "Returns card statistics based on card property" do

    before(:all) do
      @mingle_wall = MingleWallSnapshot.new(@xml_string, @xml_live_card)
    end

    it "return nill when given a Type that is not supported" do
      expect(@mingle_wall.number_of_cards_of_type('not supported type')).to be_nil
    end

    it "always returns 0 for number of cards for a given Type when cards array is empty" do
      @mingle_wall = MingleWallSnapshot.new('', @xml_live_card)

      expect(@mingle_wall.number_of_cards_of_type('Story')).to eq 0
      expect(@mingle_wall.number_of_cards_of_type('Defect')).to eq 0
      expect(@mingle_wall.number_of_cards_of_type('Power Ups')).to eq 0
    end

    it "always returns 0 for number of cards for a given Status when cards array is empty" do
      @mingle_wall = MingleWallSnapshot.new('', @xml_live_card)

      expect(@mingle_wall.number_of_cards_with_status('Next')).to eq 0
      expect(@mingle_wall.number_of_cards_with_status('Dev')).to eq 0
      expect(@mingle_wall.number_of_cards_with_status('Dev done')).to eq 0
      expect(@mingle_wall.number_of_cards_with_status('A & D')).to eq 0
      expect(@mingle_wall.number_of_cards_with_status('A & D done')).to eq 0
      expect(@mingle_wall.number_of_cards_with_status('QA')).to eq 0
      expect(@mingle_wall.number_of_cards_with_status('QA done')).to eq 0
    end

    it "returns 4 as number of cards of type Story" do
      expect(@mingle_wall.number_of_cards_of_type('Story')).to eq 4
    end

    it "returns 2 as number of cards of type Story" do
      expect(@mingle_wall.number_of_cards_of_type('Defect')).to eq 2
    end

    it "returns 1 as number of cards of type Story" do
      expect(@mingle_wall.number_of_cards_of_type('Power Ups')).to eq 1
    end

    it "returns 0 when no cards for the given Type is not found" do
      expect(@mingle_wall.number_of_cards_of_type('TWS Content')).to eq 0
    end

    it "return nill when given a Status that is not supported" do
      expect(@mingle_wall.number_of_cards_with_status('not supported status')).to be_nil
    end

    it "return 3 as number of cards in Status 'Next'" do
      expect(@mingle_wall.number_of_cards_with_status('Next')).to be 3
    end

    it "return 2 as number of cards in Status 'Dev done'" do
      expect(@mingle_wall.number_of_cards_with_status('Dev done')).to be 2
    end

    it "return 1 as number of cards in Status 'Dev'" do
      expect(@mingle_wall.number_of_cards_with_status('Dev')).to be 1
    end

    it "return 0 when no cards for the given Status is not found" do
      expect(@mingle_wall.number_of_cards_with_status('A & D')).to be 0
    end

  end

end
