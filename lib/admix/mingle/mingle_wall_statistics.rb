class MingleWallStatistics

  def initialize(mingle_wall)
    @mingle_wall = mingle_wall
  end

  def statistics_for_cfd
    { 'QA' => @mingle_wall.number_of_cards_with_status('QA'),
      'QA done' => @mingle_wall.number_of_cards_with_status('QA done'),
      'Dev' => @mingle_wall.number_of_cards_with_status('Dev'),
      'Dev done' => @mingle_wall.number_of_cards_with_status('Dev done'),
      'A & D done' => @mingle_wall.number_of_cards_with_status('A & D done'),
      'A & D' => @mingle_wall.number_of_cards_with_status('A & D'),
      'Next' => @mingle_wall.number_of_cards_with_status('Next')
    }
  end

end