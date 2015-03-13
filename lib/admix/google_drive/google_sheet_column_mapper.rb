require_relative '../admix/mingle/card_status'

class GoogleSheetColumnMapper

  attr_reader :mapping

  #TODO allow custom mapping from settings

  def self.mapping
    @mapping = {
        CardStatus.NEXT => '1',
        CardStatus.DEV => '2',
        CardStatus.DEV_DONE => '3',
        CardStatus.QA => '3',
        CardStatus.QA_DONE => '5',
        CardStatus.AD => '6',
        CardStatus.AD_DONE => '7'
    }
  end

  def self.mapping_for_column(column)
    get_mapping(column)
  end

  private
  def self.get_mapping (value)
    @mapping.each do |k, v|
      return {k => v} if v == value
    end
  end
end