require 'rest-client'

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

  class XMLTransformation

  	attr_reader :parsed_xml

  	def initialize(xml_string)
  	  @parsed_xml = Nokogiri::XML(xml_string)
  	end

  	def number_of_tag_occurences(tag_name)
  	  @parsed_xml.xpath("//#{tag_name}").count
  	end
  end
end