require 'yaml'

class MQLWrapper

  MQL_START_STATE = "SELECT COUNT(*) WHERE "
  OR = " OR "

  def initialize(file)
    @file = File.read(file)
  end

  def parseYAML
    filters = yaml_filters
    mql_for_types = get_types(filters)

    return MQL_START_STATE + mql_for_types
  end

  private

  def yaml_filters
    yaml_obj = YAML.load @file
    yaml_obj['filters']
  end

  def filters_for_key(filter, key)
    filter.each do |f|
      if f.has_key?(key)
        return f[key]
      end
    end
  end

  def get_types(filter)
    types = filters_for_key(filter, "Type")
    return '' if types.nil?

    if types.is_a?(Array)
      statement_for_types_in_array(types)
    else
      negating = is_negating?(types)
      types.slice!('not ')
      negating ? "Type != #{types}":"Type = #{types}"
    end
  end

  def statement_for_types_in_array(types)
    mql_statement = statement_for_single_typ(types.delete_at(0))
    types.each {
        |type| mql_statement += OR + statement_for_single_typ(type)
    }
    mql_statement
  end

  def statement_for_single_typ(type)
    negating = is_negating?(type)
    type.slice!('not ')
    negating ? "Type != #{type}":"Type = #{type}"
  end

  def is_negating?(clause)
    clause.start_with?('not ')
  end

end