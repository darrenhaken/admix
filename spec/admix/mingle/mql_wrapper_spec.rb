require 'rspec'

require_relative '../../../lib/admix/mingle/mql_wrapper'

RSpec.describe MQLWrapper do

  before(:all) do
    @yaml_assets_path = "../../../assets/yaml/"
  end

  describe "Parse a YAML string to MQL for 'SELECT COUNT(*) WHERE' for filter with type 'Type'" do

    it "formats a valid MQL given YAML with one Type filter" do
      yaml_file = File.expand_path(@yaml_assets_path + 'one_type_filter.yaml', __FILE__)
      mql_wrapper = MQLWrapper.new(yaml_file)
      expected_mql = "SELECT COUNT(*) WHERE Type = Story"

      result = mql_wrapper.parseYAML

      expect(result).to eq expected_mql
    end

    it "formats a valid MQL given YAML with one Type filter in an array" do
      yaml_file = File.expand_path(@yaml_assets_path + 'one_type_filter_in_array.yaml', __FILE__)
      mql_wrapper = MQLWrapper.new(yaml_file)
      expected_mql = "SELECT COUNT(*) WHERE Type = Story"

      result = mql_wrapper.parseYAML

      expect(result).to eq expected_mql
    end

    it "formats a valid MQL given YAML with two Type filter in an array" do
      yaml_file = File.expand_path(@yaml_assets_path + 'two_types_filter.yaml', __FILE__)
      mql_wrapper = MQLWrapper.new(yaml_file)
      expected_mql = "SELECT COUNT(*) WHERE Type = Story OR Type = Defect"

      result = mql_wrapper.parseYAML

      expect(result).to eq expected_mql
    end

    it "formats a valid MQL given YAML with three Type filter in an array" do
      yaml_file = File.expand_path(@yaml_assets_path + 'three_types_filter.yaml', __FILE__)
      mql_wrapper = MQLWrapper.new(yaml_file)
      expected_mql = "SELECT COUNT(*) WHERE Type = Story OR Type = Defect OR Type = Power Ups"

      result = mql_wrapper.parseYAML

      expect(result).to eq expected_mql
    end

    it "formats a valid MQL given YAML containing '!' for a negating Type" do
      yaml_file = File.expand_path(@yaml_assets_path + 'single_negate_type_filter.yaml', __FILE__)
      mql_wrapper = MQLWrapper.new(yaml_file)
      expected_mql = "SELECT COUNT(*) WHERE Type != Story"

      result = mql_wrapper.parseYAML

      expect(result).to eq expected_mql
    end

    it "formats a valid MQL given YAML containing '!' for a negating Type in an array" do
      yaml_file = File.expand_path(@yaml_assets_path + 'negative_type_filter_in_array.yaml', __FILE__)
      mql_wrapper = MQLWrapper.new(yaml_file)
      expected_mql = "SELECT COUNT(*) WHERE Type != Story OR Type != Defect OR Type != Power Ups"

      result = mql_wrapper.parseYAML

      expect(result).to eq expected_mql
    end

    it "formats a valid MQL given YAML containing a mix of negative and non-negative Type in an array" do
      yaml_file = File.expand_path(@yaml_assets_path + 'mix_type_filter_in_array.yaml', __FILE__)
      mql_wrapper = MQLWrapper.new(yaml_file)
      expected_mql = "SELECT COUNT(*) WHERE Type = Story OR Type != Defect OR Type != Power Ups"

      result = mql_wrapper.parseYAML

      expect(result).to eq expected_mql
    end

  end
end