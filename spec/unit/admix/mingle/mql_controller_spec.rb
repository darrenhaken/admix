require 'rspec'


require_relative '../../../../lib/admix/mingle/mql_controller'
require_relative '../../../../lib/admix/mingle/mingle_query_language/mql_card_property'

RSpec.describe MQLController do

  before(:all) do
    @yaml_assets_path = "../../../../assets/yaml/"
    @card_property_to_select = MQLCardProperty.name.and(MQLCardProperty.type).and(MQLCardProperty.status)
  end

  it 'returns "SELECT name, type, status WHERE Type is Story"' do
    yaml_file = File.expand_path(@yaml_assets_path + 'one_type_filter.yaml', __FILE__)
    controller = MQLController.new(yaml_file)
    expected_mql = "SELECT name, type, status WHERE Type is Story"

    result = controller.format_select_statement_for_cards(@card_property_to_select)

    expect(result).to eq expected_mql
    end

  it 'returns a valid string for MQL for a single type and status' do
    yaml_file = File.expand_path(@yaml_assets_path + 'filter_for_single_typ_and_status.yaml', __FILE__)
    controller = MQLController.new(yaml_file)
    expected_mql = "SELECT name, type, status WHERE (Status is 'A & D done') AND (Type is 'Power Ups')"

    result = controller.format_select_statement_for_cards(@card_property_to_select)

    expect(result).to eq expected_mql
  end

  it "returns MQL statement that returns count only " do
    yaml_file = File.expand_path(@yaml_assets_path + 'filter_for_single_typ_and_status.yaml', __FILE__)
    controller = MQLController.new(yaml_file)
    expected_mql = "SELECT COUNT(*) AS OF '#{Time.now.strftime("%d/%m/%Y")}' WHERE ('Moved to production date' > '04/11/2014') AND (Type is 'Power Ups')"

    result = controller.format_count_statement_for_card_live_since('04/11/2014')

    expect(result).to eq expected_mql
  end

  it "returns MQL statement for cards in a given day" do
    yaml_file = File.expand_path(@yaml_assets_path + 'filter_for_single_typ_and_status.yaml', __FILE__)
    controller = MQLController.new(yaml_file)
    expected_mql = "SELECT name, type, status AS OF '15/03/2014' WHERE (Status is 'A & D done') AND (Type is 'Power Ups')"

    result = controller.format_select_statement_for_cards_in_date(@card_property_to_select, '15/03/2014')

    expect(result).to eq expected_mql
  end

end