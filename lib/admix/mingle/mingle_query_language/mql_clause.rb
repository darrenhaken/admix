class MQLClause


  attr_reader :clause

  def initialize(clause)
    @clause = clause
  end

  STATUS_IS = 'Status is'
  def self.status_is(status)
    status = surround_by_quotation_if_not_single_word(status)
    MQLClause.new("#{STATUS_IS} #{status}")
  end

  def self.status_is_not(status)
    status = surround_by_quotation_if_not_single_word(status)
    MQLClause.new("#{STATUS_IS} not #{status}")
  end

  TYPE_IS = 'Type is'
  def self.type_is(type)
    type = surround_by_quotation_if_not_single_word(type)
    MQLClause.new("#{TYPE_IS} #{type}")
  end

  def self.type_is_not(type)
    type = surround_by_quotation_if_not_single_word(type)
    MQLClause.new("#{TYPE_IS} not #{type}")
  end

  MOVED_TO = 'Moved to'
  def self.moved_to_is_larger_than_date(card_status, date)
    MQLClause.new("\'#{MOVED_TO} #{card_status} date\' > \'#{date}\'")
  end

  def or(another_clause)
    MQLClause.new("#{clause} OR #{another_clause.clause}")
  end

  def and(another_clause)
    MQLClause.new("(#{clause}) AND (#{another_clause.clause})")
  end

  private
  def self.is_single_word?(string)
    string.scan(/[\w'-]+/).length == 1
  end

  def self.surround_by_quotation_if_not_single_word(string)
    is_single_word?(string)? string:"'#{string}'"
  end
end