require 'rspec'

require_relative '../../../../lib/admix/mingle/mingle_wall_snapshot'
require_relative '../../../../lib/admix/mingle/card_status'
require_relative '../../../../lib/admix/cumulative_flow_diagram_logic/mingle_cfd_data_point'


RSpec.describe MingleCfdDataPoint do

  before(:each) do
    @mingle_wall = instance_double(MingleWallSnapshot)
    @cfd_data_point = MingleCfdDataPoint.new(@mingle_wall)
    allow(@mingle_wall).to receive(:number_of_cards_with_status){0}
    allow(@mingle_wall).to receive(:number_of_live_cards){0}
  end

  it 'returns a Hash containing Mingle wall statistics' do
    result = @cfd_data_point.data_point

    expect(result).to be_a Hash
  end

  it "returns Hash which contains the following keys needed for Commultive Flow Digram" do
    keys = ['QA', 'QA done', 'Dev done', 'Dev', 'A & D done', 'A & D', 'Next', 'Done (Deployed to Live)']

    result = @cfd_data_point.data_point

    expect(result.keys).to contain_exactly *keys
  end

  it "returns values for the commultive flow digram" do
    _QA = 2
    allow(@mingle_wall).to receive(:number_of_cards_with_status).with('QA'){_QA}

    _QA_done = 1
    allow(@mingle_wall).to receive(:number_of_cards_with_status).with('QA done'){_QA_done}

    _Dev = 3
    allow(@mingle_wall).to receive(:number_of_cards_with_status).with('Dev'){_Dev}

    _Dev_done = 0
    allow(@mingle_wall).to receive(:number_of_cards_with_status).with('Dev done'){_Dev_done}

    _Next = 5
    allow(@mingle_wall).to receive(:number_of_cards_with_status).with('Next'){_Next}

    _AD = 0
    allow(@mingle_wall).to receive(:number_of_cards_with_status).with('A & D'){_AD}

    _AD_done = 1
    allow(@mingle_wall).to receive(:number_of_cards_with_status).with('A & D done'){_AD_done}

    _LIVE = 10
    allow(@mingle_wall).to receive(:number_of_live_cards){10}
    result = @cfd_data_point.data_point

    expect(result[CardStatus.QA]).to eq _QA
    expect(result[CardStatus.QA_DONE]).to eq _QA_done
    expect(result[CardStatus.DEV]).to eq _Dev
    expect(result[CardStatus.DEV_DONE]).to eq _Dev_done
    expect(result[CardStatus.NEXT]).to eq _Next
    expect(result[CardStatus.AD]).to eq _AD
    expect(result[CardStatus.AD_DONE]).to eq _AD_done
    expect(result[CardStatus.LIVE]).to eq _LIVE
  end
end