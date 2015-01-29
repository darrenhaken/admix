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
      	raise "should this raise an exception?"
      end
      response.body
    end
  end

  class MingleWallSnapshot

  	EXPECTED_DATE_FORMAT = "%Y-%m-%d"

  	def initialize xml_string
  	  @mingle_wall_hash = Nori.new.parse(xml_string)
  	end

  	def number_of_cards_with_status card_status
  	  (list_of_cards_with_status card_status).size
  	end

  	def number_of_cards_that_went_live_since date, card_status
      live_cards = list_of_cards_with_status card_status
      number_of_valid_cards = live_cards.reduce(0) do | number_of_valid_live_cards, live_card | 
        number_of_valid_live_cards += 1 if live_card_has_moved_to_production date, live_card['properties']
      end
      number_of_valid_cards.to_i
  	end

  	private

      def live_card_has_moved_to_production date, card_properties
        return card_properties.any? do | property | 
          property['name'] == 'Moved to production date' && Date.parse(property['value'].to_s, EXPECTED_DATE_FORMAT) >= date
        end
      end

  	  def list_of_cards_with_status card_status
  	    cards_with_matching_status = []
  	  	@mingle_wall_hash['cards'].each do | card |
  	  	  if card_status_is card_status, card['properties']
  	  	    cards_with_matching_status << card
  	  	  end
  	  	end
  	    cards_with_matching_status
  	  end

  	  def card_status_is card_status, card_properties
        return card_properties.any? do | property | 
          property['name'] == 'Status' && property['value'] == card_status
        end
  	  end
  end
end