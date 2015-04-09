require 'yaml'

require_relative 'mingle_query_language/mql_clause'

class MQLParser

  def self.parse_type_filters_to_mql_clause(file)
    types_filters = get_filters_in_file_for(file, "Type")
    parse_filters_for_type(types_filters)
  end

  def self.parse_status_filters_to_mql_clause(file)
    status_filters = get_filters_in_file_for(file, "Status")
    parse_filters_for_status(status_filters)
  end

  private
  def self.get_filters_in_file_for(file, key)
    filters = yaml_filters(File.read(file))
    filters_for_key(filters, key)
  end

  def self.parse_filters_for_status(status)
    return nil if status.nil?
    return mql_clauses_for_filters_in_array(status, &:mql_clause_for_a_status) if status.is_a?(Array)
    mql_clause_for_a_status(status)
  end

  def self.parse_filters_for_type(types)
    return nil if types.nil?
    return mql_clauses_for_filters_in_array(types, &:mql_clause_for_a_type) if types.is_a?(Array)
    mql_clause_for_a_type(types)
  end

  def self.mql_clause_for_a_status(status)
    status.slice!('= ')
    MQLClause.status_is(status)
  end

  def self.mql_clause_for_a_type(type)
    negating = type.slice!('not ')
    is_negating?(negating)? MQLClause.type_is_not(type):MQLClause.type_is(type)
  end

  def self.mql_clauses_for_filters_in_array(filters, &mql_clause_for_single_filter)
    mql_clause = mql_clause_for_single_filter.call(MQLParser, filters.shift)
    filters.each {
        |filter| mql_clause = mql_clause.or(mql_clause_for_single_filter.call(MQLParser, filter))
    }
    mql_clause
  end

  def self.yaml_filters(file)
    yaml_obj = YAML.load(file)
    yaml_obj['filters']
  end

  def self.filters_for_key(filter, key)
    filter.each{|f| return f[key] if f.has_key?(key)}
    return nil
  end

  def self.is_negating?(clause)
    return false if clause.nil?
    clause.start_with?('not ')
  end
end