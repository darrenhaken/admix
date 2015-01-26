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

  	def initialize xml_string
  	  @mingle_wall_hash = Nori.new.parse(xml_string)
  	end

  	def number_of_cards_with_status(card_status)
  	  @cards_with_status = 0
  	  @mingle_wall_hash['cards'].each do | card |
  	  	if card_status_is card_status, card
  	  	  @cards_with_status += 1
  	  	end
  	  end
  	  return @cards_with_status
  	end

  	private

  	  def card_status_is card_status, card_hash
  	  	card_hash['properties'].each do | property |
  	  	  if property['name'] == 'Status' && property['value'] == card_status
  	  	  	return true
  	  	  end
  	  	end
  	  	return false
  	  end

  end
end