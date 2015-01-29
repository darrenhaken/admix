require 'rest-client'
require 'nori'

module Admix

  class MingleResource
    def initialize(restful_resource)
      @mingle_resource = restful_resource
    end

    def get_cards
      response = @mingle_resource.get
      return response.body if response.code == 200
      raise "should this raise an exception?"
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
      valid_live_cards = live_cards.select do | live_card |
        live_card_has_moved_to_production date, live_card['properties']
      end
      valid_live_cards.size
  	end

  	private

      def live_card_has_moved_to_production date, card_properties
        return card_properties.any? do | property | 
          property['name'] == 'Moved to production date' && Date.parse(property['value'].to_s, EXPECTED_DATE_FORMAT) >= date
        end
      end

  	  def list_of_cards_with_status card_status
        @mingle_wall_hash['cards'].select do | card |
          card_status_is card_status, card['properties']
        end
  	  end

  	  def card_status_is card_status, card_properties
        return card_properties.any? do | property | 
          property['name'] == 'Status' && property['value'] == card_status
        end
  	  end
  end
end