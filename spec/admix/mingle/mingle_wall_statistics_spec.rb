require 'rspec'

require_relative '../../../lib/admix/mingle/mingle_wall_snapshot'
require_relative '../../../lib/admix/mingle/mingle_wall_statistics'

describe MingleWallStatistics do

  before(:each) do
    @mingle_wall = instance_double(MingleWallSnapshot)
    @mingle_statistics = MingleWallStatistics.new(@mingle_wall)
    allow(@mingle_wall).to receive(:number_of_cards_with_status){0}
  end

  it 'returns a Hash containing Mingle wall statistics' do
    result = @mingle_statistics.statistics_for_cfd

    expect(result).to be_a Hash
  end

  it "returns Hash which contains the following keys needed for Commultive Flow Digram" do
    keys = ['QA', 'QA done', 'Dev done', 'Dev', 'A & D done', 'A & D', 'Next']

    result = @mingle_statistics.statistics_for_cfd

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


    result = @mingle_statistics.statistics_for_cfd

    expect(result['QA']).to eq _QA
    expect(result['QA done']).to eq _QA_done
    expect(result['Dev']).to eq _Dev
    expect(result['Dev done']).to eq _Dev_done
    expect(result['Next']).to eq _Next
    expect(result['A & D']).to eq _AD
    expect(result['A & D done']).to eq _AD_done
  end
end