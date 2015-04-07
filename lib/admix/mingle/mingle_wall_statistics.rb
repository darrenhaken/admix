require_relative '../../../lib/admix/mingle/card_status'

class MingleWallStatistics

  def initialize(mingle_wall)
    @mingle_wall = mingle_wall
  end

  def statistics_for_cfd
    {
        CardStatus.QA => @mingle_wall.number_of_cards_with_status('QA'),
        CardStatus.QA_DONE => @mingle_wall.number_of_cards_with_status('QA done'),
        CardStatus.DEV => @mingle_wall.number_of_cards_with_status('Dev'),
        CardStatus.DEV_DONE => @mingle_wall.number_of_cards_with_status('Dev done'),
        CardStatus.AD_DONE => @mingle_wall.number_of_cards_with_status('A & D done'),
        CardStatus.AD => @mingle_wall.number_of_cards_with_status('A & D'),
        CardStatus.NEXT => @mingle_wall.number_of_cards_with_status('Next'),
        CardStatus.LIVE => @mingle_wall.number_of_live_cards
    }
  end

end