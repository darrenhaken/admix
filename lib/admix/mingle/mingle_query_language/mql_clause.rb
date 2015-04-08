class MQLClause


  attr_reader :clause

  def initialize(clause)
    @clause = clause
  end

  STATUS_IS = 'Status is'

  def self.status_is(status)
     MQLClause.new("#{STATUS_IS} #{status}")
  end

  def self.status_is_not(status)
    MQLClause.new("#{STATUS_IS} not #{status}")
  end

  TYPE_IS = 'Type is'

  def self.type_is(type)
    MQLClause.new("#{TYPE_IS} #{type}")
  end

  def self.type_is_not(type)
    MQLClause.new("#{TYPE_IS} not #{type}")
  end

  def or(another_clause)
    MQLClause.new("#{clause} OR #{another_clause.clause}")
  end

  def and(another_clause)
    MQLClause.new("(#{clause}) AND (#{another_clause.clause})")
  end
end