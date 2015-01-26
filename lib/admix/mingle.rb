require 'rest-client'
require 'nori'

module Admix

  class MingleResource
    def initialize(restful_resource)
      @mingle_resource = restful_resource
    end

    def get_cards
      response = @mingle_resource.get
      if response.code != 200
      	return "should this raise an exception?"
      end
      response.body
    end
  end

  class MingleWallSnapshot

  	EXPECTED_DATE_FORMAT = "%Y%m/%d/"

  	def initialize xml_string
  	  @mingle_wall_hash = Nori.new.parse(xml_string)
  	end

  	def number_of_cards_with_status card_status
  	  (list_of_cards_with_status card_status).size
  	end

  	def number_of_cards_that_went_live_since date, card_status
  	  cards_gone_live = list_of_cards_with_status card_status
  	  number_of_valid_live_cards = 0
  	  cards_gone_live.each do | live_card |
  	  	live_card['properties'].each do | property |
  	  	  if property['name'] == 'Moved to production date' && Date.parse(property['value'].to_s, EXPECTED_DATE_FORMAT) >= date
  	  	  	number_of_valid_live_cards =+ 1
  	  	  end
  	  	end
  	  end
  	  number_of_valid_live_cards
  	end

  	private

  	  def list_of_cards_with_status card_status
  	    cards_with_matching_status = []
  	  	@mingle_wall_hash['cards'].each do | card |
  	  	  if card_status_is card_status, card
  	  	    cards_with_matching_status << card
  	  	  end
  	  	end
  	    return cards_with_matching_status
  	  end

  	  def card_status_is card_status, card_hash
  	  	card_hash['properties'].each do | property |
  	  	  if property['name'] == 'Status' && property['value'] == card_status
  	  	  	return true
  	  	  end
  	  	end
  	  	return false
  	  end
  end

  class GoogleDriveSpreadsheet

  end
end