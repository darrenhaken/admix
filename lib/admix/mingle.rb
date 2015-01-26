require 'rest-client'

module Admix

  class CardStatus

  end

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

  class XMLTransformation

  	attr_reader :parsed_xml

  	def initialize(xml_string)
  	  @parsed_xml = Nokogiri::XML(xml_string)
  	end

  	def number_of_tag_occurences(tag_name)
  	  @parsed_xml.xpath("//#{tag_name}").count
  	end

  	def number_of_stories_gone_live_since(date_time)
  	  gone_live = 0
  	  number_of_cards = @parsed_xml.xpath("//card").count
  	  number_of_cards.times do | card_number |
  	  	if @parsed_xml.xpath("//card[#{card_number}]/properties").to_s.include? "Done (Deployed to Live)"
  	  		gone_live =+ 1
  	  	end
  	  end
  	  gone_live
  	end
  end
end