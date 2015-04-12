require 'nori'

require_relative '../../../lib/admix/mingle/mingle_card'

class MingleWallSnapshot

  CARD_TYPES = ['Story', 'Defect', 'Power Ups', 'TWS Story', 'TWS Content', 'TWS Bug', 'Content', 'Epic', 'Unplanned']
  CARD_STATUS = ['Next', 'A & D', 'A & D done', 'Dev', 'Dev done', 'QA', 'QA done', 'Done (Deployed to Live)',
                 'Deleted', 'NEXT BAU', 'Technical debt backlog', 'Defect backlog', 'Story backlog',
                 'New Customer Request', 'Ready for Development', 'Ready For Next', 'Blocked on external dependencies',
                 'Waster', 'Waste']

  attr_reader :cards, :number_of_live_cards

  def initialize(xml_cards_data, xml_live_card_counts)
    @cards = parse_xml(xml_cards_data, true)
    @number_of_live_cards = parse_xml(xml_live_card_counts, false)
  end

  def number_of_cards_with_status(card_status)
    number_of_cards(card_status, CARD_STATUS){|card| card.status == card_status}
  end

  def number_of_cards_of_type(card_type)
    number_of_cards(card_type, CARD_TYPES){|card| card.type == card_type}
  end

  private
  def number_of_cards(card_key, accepted_keys, &selection_block)
    return 0 if @cards.nil?
    return nil unless accepted_keys.include?(card_key)
    num_of_cards = @cards.select{|card| selection_block.call(card)}
    num_of_cards.length
  end

  def parse_xml(xml_string, parse_cards)
    cards_hash = Nori.new.parse(xml_string)
    return nil if cards_hash.empty?

    if(parse_cards)
      @cards = []
      cards_hash['results'].each do |card|
        @cards << MingleCard.new(card['name'], card['status'], card['type'])
      end
      @cards
    else
      result = cards_hash['results'][0]
      result['count'].to_i
    end
  end

end