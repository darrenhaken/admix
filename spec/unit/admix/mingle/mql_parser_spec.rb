require 'rspec'

require_relative '../../../../lib/admix/mingle/mql_parser'

RSpec.describe MQLParser do

  before(:all) do
    @yaml_assets_path = "../../../../assets/yaml/"
    @select_element = "COUNT(*)"
  end

  describe "Parse a YAML string to MQL for 'SELECT COUNT(*) WHERE' for filter with type 'Type'" do

    it "formats a valid MQL given YAML with one Type filter" do
      yaml_file = File.expand_path(@yaml_assets_path + 'one_type_filter.yaml', __FILE__)
      mql_parser = MQLParser.new(yaml_file, @select_element)
      expected_mql = "SELECT COUNT(*) WHERE Type = Story"

      result = mql_parser.parse

      expect(result).to eq expected_mql
    end

    it "formats a valid MQL given YAML with one Type filter in an array" do
      yaml_file = File.expand_path(@yaml_assets_path + 'one_type_filter_in_array.yaml', __FILE__)
      mql_parser = MQLParser.new(yaml_file, @select_element)
      expected_mql = "SELECT COUNT(*) WHERE Type = Story"

      result = mql_parser.parse

      expect(result).to eq expected_mql
    end

    it "formats a valid MQL given YAML with two Type filter in an array" do
      yaml_file = File.expand_path(@yaml_assets_path + 'two_types_filter.yaml', __FILE__)
      mql_parser = MQLParser.new(yaml_file, @select_element)
      expected_mql = "SELECT COUNT(*) WHERE Type = Story OR Type = Defect"

      result = mql_parser.parse

      expect(result).to eq expected_mql
    end

    it "formats a Type value that contains more than one word between quotation" do
      yaml_file = File.expand_path(@yaml_assets_path + 'multi_word_type_with_filter.yaml', __FILE__)
      mql_parser = MQLParser.new(yaml_file, @select_element)
      expected_mql = "SELECT COUNT(*) WHERE Type = Story OR Type = 'Power Ups'"

      result = mql_parser.parse

      expect(result).to eq expected_mql
    end

    it "formats a valid MQL given YAML with three Type filter in an array" do
      yaml_file = File.expand_path(@yaml_assets_path + 'three_types_filter.yaml', __FILE__)
      mql_parser = MQLParser.new(yaml_file, @select_element)
      expected_mql = "SELECT COUNT(*) WHERE Type = Story OR Type = Defect OR Type = 'Power Ups'"

      result = mql_parser.parse

      expect(result).to eq expected_mql
    end

    it "formats a valid MQL given YAML containing '!' for a negating Type" do
      yaml_file = File.expand_path(@yaml_assets_path + 'single_negate_type_filter.yaml', __FILE__)
      mql_parser = MQLParser.new(yaml_file, @select_element)
      expected_mql = "SELECT COUNT(*) WHERE Type != Story"

      result = mql_parser.parse

      expect(result).to eq expected_mql
    end

    it "formats a valid MQL given YAML containing '!' for a negating Type in an array" do
      yaml_file = File.expand_path(@yaml_assets_path + 'negative_type_filter_in_array.yaml', __FILE__)
      mql_parser = MQLParser.new(yaml_file, @select_element)
      expected_mql = "SELECT COUNT(*) WHERE Type != Story OR Type != Defect OR Type != 'Power Ups'"

      result = mql_parser.parse

      expect(result).to eq expected_mql
    end

    it "formats a valid MQL given YAML containing a mix of negative and non-negative Type in an array" do
      yaml_file = File.expand_path(@yaml_assets_path + 'mix_type_filter_in_array.yaml', __FILE__)
      mql_parser = MQLParser.new(yaml_file, @select_element)
      expected_mql = "SELECT COUNT(*) WHERE Type = Story OR Type != Defect OR Type != 'Power Ups'"

      result = mql_parser.parse

      expect(result).to eq expected_mql
    end
  end

  describe "Parse a YAML string to MQL for 'SELECT COUNT(*) WHERE' for filter with type 'Status'" do

    it "formats a valid MQL given YAML containing one 'Status' filter" do
      yaml_file = File.expand_path(@yaml_assets_path + 'one_status_filter.yaml', __FILE__)
      mql_parser = MQLParser.new(yaml_file, @select_element)
      expected_mql = "SELECT COUNT(*) WHERE Status = Next"

      result = mql_parser.parse

      expect(result).to eq expected_mql
    end

    it "formats a valid MQL given YAML containing multiple 'Status' filter" do
      yaml_file = File.expand_path(@yaml_assets_path + 'multiple_status_filter.yaml', __FILE__)
      mql_parser = MQLParser.new(yaml_file, @select_element)
      expected_mql = "SELECT COUNT(*) WHERE Status = Next OR Status = Dev"

      result = mql_parser.parse

      expect(result).to eq expected_mql
    end

    it "formats a Status that contains more than one word between quotation" do
      yaml_file = File.expand_path(@yaml_assets_path + 'multi_word_status_with_filter.yaml', __FILE__)
      mql_parser = MQLParser.new(yaml_file, @select_element)
      expected_mql = "SELECT COUNT(*) WHERE Status = 'Dev done' OR Status <= 'A & D done' OR Status > Next"

      result = mql_parser.parse

      expect(result).to eq expected_mql
    end
  end

  describe "Parse a YAML string to MQL for 'SELECT COUNT(*) WHERE' for filter containing 'Type' and 'Status'" do
    it "formats a filter that contains one filter based on Type, and another based on Status" do
      yaml_file = File.expand_path(@yaml_assets_path + 'filter_for_single_typ_and_status.yaml', __FILE__)
      mql_parser = MQLParser.new(yaml_file, @select_element)
      expected_mql = "SELECT COUNT(*) WHERE (Type = 'Power Ups') AND (Status <= 'A & D done')"

      result = mql_parser.parse

      expect(result).to eq expected_mql
    end

    describe "Generate MQL string that returns number of cards in Live since given date for the card types in filter" do
      it "returns MQL statement that returns count only " do
        yaml_file = File.expand_path(@yaml_assets_path + 'filter_for_single_typ_and_status.yaml', __FILE__)
        mql_parser = MQLParser.new(yaml_file, @select_element)
        expected_mql = "SELECT COUNT(*) WHERE 'Moved to production date' > '04/11/2014'  AND (Type = 'Power Ups')"

        result = mql_parser.statement_for_count_since('04/11/2014')

        expect(result).to eq expected_mql
      end
    end

  end

end