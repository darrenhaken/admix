class MQLCardProperty

  attr_reader :property

  def initialize(property)
    @property = property
  end

  def and(another_mql_property)
    MQLCardProperty.new("#{property}, #{another_mql_property.property}")
  end

  def self.name()
    MQLCardProperty.new('name')
  end

  def self.status()
    MQLCardProperty.new('status')
  end

  def self.type()
    MQLCardProperty.new('type')
  end

  def self.count()
    MQLCardProperty.new('COUNT(*)')
  end
  
end