require 'rspec'

require_relative '../../../../lib/admix/mingle/mql_parser'
require_relative '../../../../lib/admix/mingle/mingle_query_language/mql_clause'

RSpec.describe MQLParser do

  before(:all) do
    @yaml_assets_path = "../../../../assets/yaml/"
    @select_element = "COUNT(*)"
  end

  describe "Parse Mingle filters for Type in a yaml file to MQLClause object" do
    it "returns MQLClause object with the clause 'Type is Story'" do
      yaml_file = File.expand_path(@yaml_assets_path + 'one_type_filter.yaml', __FILE__)
      expected_result = "Type is Story"

      result = MQLParser.parse_type_filters_to_mql_clause(yaml_file)

      expect(result).to be_a MQLClause
      expect(result.clause).to eq expected_result
    end

    it "returns MQLClause object with the clause 'Type is Story' if filter is in a yaml array" do
      yaml_file = File.expand_path(@yaml_assets_path + 'one_type_filter_in_array.yaml', __FILE__)
      expected_result = "Type is Story"

      result = MQLParser.parse_type_filters_to_mql_clause(yaml_file)

      expect(result).to be_a MQLClause
      expect(result.clause).to eq expected_result
    end

    it "returns MQLClause object with the clause 'Type is Story OR Type is Defect'" do
      yaml_file = File.expand_path(@yaml_assets_path + 'two_types_filter.yaml', __FILE__)
      expected_result = "Type is Story OR Type is Defect"

      result = MQLParser.parse_type_filters_to_mql_clause(yaml_file)

      expect(result).to be_a MQLClause
      expect(result.clause).to eq expected_result
      end

    it "returns MQLClause object with the clause 'Type is Story OR Type is 'Power Ups''" do
      yaml_file = File.expand_path(@yaml_assets_path + 'multi_word_type_with_filter.yaml', __FILE__)
      expected_result = "Type is Story OR Type is 'Power Ups'"

      result = MQLParser.parse_type_filters_to_mql_clause(yaml_file)

      expect(result).to be_a MQLClause
      expect(result.clause).to eq expected_result
    end

    it "returns MQLClause object with the clause 'Type is Story OR Type is Defect OR Type is 'Power Ups''" do
      yaml_file = File.expand_path(@yaml_assets_path + 'multi_word_type_with_filter.yaml', __FILE__)
      expected_result = "Type is Story OR Type is 'Power Ups'"

      result = MQLParser.parse_type_filters_to_mql_clause(yaml_file)

      expect(result).to be_a MQLClause
      expect(result.clause).to eq expected_result
    end

    it "returns MQLClause object with a negating clause given YAML containing '!' for a negating Type" do
      yaml_file = File.expand_path(@yaml_assets_path + 'single_negate_type_filter.yaml', __FILE__)
      expected_result = "Type is not Story"

      result = MQLParser.parse_type_filters_to_mql_clause(yaml_file)

      expect(result).to be_a MQLClause
      expect(result.clause).to eq expected_result
      end

    it "returns MQLClause object with a negating clause given YAML containing '!' for a negating Type in an array" do
      yaml_file = File.expand_path(@yaml_assets_path + 'negative_type_filter_in_array.yaml', __FILE__)
      expected_result = "Type is not Story OR Type is not Defect OR Type is not 'Power Ups'"

      result = MQLParser.parse_type_filters_to_mql_clause(yaml_file)

      expect(result).to be_a MQLClause
      expect(result.clause).to eq expected_result
      end

    it "returns MQLClause object with a mix of negating clause and non-negating clause" do
      yaml_file = File.expand_path(@yaml_assets_path + 'mix_type_filter_in_array.yaml', __FILE__)
      expected_result = "Type is Story OR Type is not Defect OR Type is not 'Power Ups'"

      result = MQLParser.parse_type_filters_to_mql_clause(yaml_file)

      expect(result).to be_a MQLClause
      expect(result.clause).to eq expected_result
    end
  end

  describe "Parse Mingle filters for Status in a yaml file to MQLClause object" do
    it "returns MQLClause object for a single Status filter" do
      yaml_file = File.expand_path(@yaml_assets_path + 'one_status_filter.yaml', __FILE__)
      expected_result = "Status is Next"

      result = MQLParser.parse_status_filters_to_mql_clause(yaml_file)

      expect(result).to be_a MQLClause
      expect(result.clause).to eq expected_result
      end

    it "returns MQLClause object for a multiple Status filter that is in an array" do
      yaml_file = File.expand_path(@yaml_assets_path + 'multiple_status_filter.yaml', __FILE__)
      expected_result = "Status is Next OR Status is Dev"

      result = MQLParser.parse_status_filters_to_mql_clause(yaml_file)

      expect(result).to be_a MQLClause
      expect(result.clause).to eq expected_result
    end
  end
end