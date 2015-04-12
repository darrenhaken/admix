require_relative 'mql_parser'
require_relative 'mingle_query_language/mql_builder'
require_relative 'mingle_query_language/mql_card_property'

class MQLController

  PRODUCTION_STATUS = 'production'

  def initialize(filter_file)
    @filter_file = filter_file
  end

  def format_select_statement_for_cards(mql_card_property)
    combined_mql_clause = build_mql_clause
    builder = MQLBuilder.select(mql_card_property).where(combined_mql_clause)
    builder.statement
  end

  def format_count_statement_for_card_live_since(date)
    format_count_statement_for_card_live_since_as_of_date(date, Time.now.strftime("%d/%m/%Y"))
  end

  def format_select_statement_for_cards_in_date(mql_card_property, date)
    combined_mql_clause = build_mql_clause
    builder = MQLBuilder.select(mql_card_property).as_of(date).where(combined_mql_clause)
    builder.statement
  end

  def format_count_statement_for_card_live_since_as_of_date(date, as_of_date)
    mql_clause_for_moved_to = MQLClause.moved_to_status_is_larger_than_date(PRODUCTION_STATUS, date)
    mql_type_clause = MQLParser.parse_type_filters_to_mql_clause(@filter_file)
    mql_clause = mql_clause_for_moved_to.and(mql_type_clause)
    builder = MQLBuilder.select(MQLCardProperty.count).as_of(as_of_date).where(mql_clause)
    builder.statement
  end

  private
  def build_mql_clause
    mql_type_clause = MQLParser.parse_type_filters_to_mql_clause(@filter_file)
    mql_status_clause = MQLParser.parse_status_filters_to_mql_clause(@filter_file)
    return mql_status_clause.and(mql_type_clause) if mql_type_clause  and mql_status_clause
    return mql_type_clause if mql_type_clause
    mql_status_clause if mql_status_clause
  end
end