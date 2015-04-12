require_relative '../../../lib/admix/mingle/card_status'

class CfdDataPointToColumnMapper

  attr_reader :mapping

  def self.mapping
    @mapping = {
        'date' => 1,
        'day' => 2,
        CardStatus.LIVE => 3,
        CardStatus.QA_DONE => 4,
        CardStatus.QA => 5,
        CardStatus.DEV_DONE => 6,
        CardStatus.DEV => 7,
        CardStatus.AD_DONE => 8,
        CardStatus.AD => 9,
        CardStatus.NEXT => 10
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