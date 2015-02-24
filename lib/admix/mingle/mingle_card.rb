class MingleCard

  attr_reader :name, :type, :status

  #TODO pass a hash with attributes and let the card poplulate itself.
  def initialize(name, status, type)
    @name = name
    @status = status
    @type = type
  end

end