require 'rest-client'

module Admix

  
  class MingleResource
    def initialize(restful_resource)
      @mingle_resource = restful_resource
    end

    def get_cards
      @mingle_resource.get.body
    end
  end


  private

    class RestResource
      def initialize(resource)
        @resource = resource
      end

      def get
        @resource.get.body
      end
    end
end