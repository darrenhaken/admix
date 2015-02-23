require 'yaml'

class MQLWrapper

  OR = " OR "
  AND = " AND "

  def initialize(file, select_elements_statement)
    @file = File.read(file)
    @mql_select_statement = "SELECT #{select_elements_statement} WHERE "
  end

  def parseYAML
    filters = yaml_filters
    mql_for_types = get_types(filters)
    mql_for_status = get_status(filters)

    if mql_for_status and mql_for_types
      @mql_select_statement + '(' + mql_for_types + ')' + AND + '(' + mql_for_status + ')'
    elsif mql_for_status
      @mql_select_statement + mql_for_status
    elsif mql_for_types
      @mql_select_statement + mql_for_types
    else
      nil
    end
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
    nil
  end

  def get_status(filters)
    status = filters_for_key(filters, "Status")
    return nil if status.nil?

    if status.is_a?(Array)
      return statement_for_status_in_array(status)
    end
    "Status #{status}"
  end

  def get_types(filter)
    types = filters_for_key(filter, "Type")
    return nil if types.nil?

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

  def statement_for_status_in_array(status)
    mql_statement = statement_for_single_status(status.delete_at(0))
    status.each {
        |a_status| mql_statement += OR + statement_for_single_status(a_status)
    }
    mql_statement
  end

  def statement_for_single_status(a_status)
    if is_single_word?(a_status)
      "Status #{a_status}"
    else
      sign = a_status.split(' ', 2)[0]
      the_status = a_status.split(' ', 2)[1]
      "Status #{sign} '#{the_status}'"
    end
  end

  def statement_for_single_typ(type)
    negating = is_negating?(type)
    type.slice!('not ')
    type = is_single_word?(type)? type:"'#{type}'"
    negating ? "Type != #{type}":"Type = #{type}"
  end

  def is_negating?(clause)
    clause.start_with?('not ')
  end

  def is_single_word?(string)
    string.scan(/[\w'-]+/).length == 1
  end
end