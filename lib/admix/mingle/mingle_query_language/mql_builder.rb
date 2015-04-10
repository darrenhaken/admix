class MQLBuilder

  attr_reader :statement

  def self.select(card_property)
    builder = new()
    builder.instance_eval{@private_statement = "SELECT #{card_property.property}"}
    builder
  end

  def where(mql_clause)
    @private_statement = "#{@private_statement} WHERE #{mql_clause.clause}"
    self
  end

  def as_of(date)
    @private_statement = "#{@private_statement} AS OF '#{date}'"
    self
  end

  def statement
    @private_statement
  end

  private
  attr :private_statement

  private_class_method :new
end