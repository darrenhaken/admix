require 'rest-client'
require 'nori'
require 'google/api_client'

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

  	def initialize(xml_string)
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

      EXPECTED_DATE_FORMAT = "%Y-%m-%d"

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

  class CumulativeFlowDiagramSpreadsheet

    ## Email of the Service Account #
    SERVICE_ACCOUNT_EMAIL = '302784193671-k58ohav0tcd6qond11l9v062q76cccvv@developer.gserviceaccount.com'

    ## Path to the Service Account's Private Key file #
    SERVICE_ACCOUNT_PKCS12_FILE_PATH = '../assets/key.p12'

    ##
    # Build a Drive client instance authorized with the service account
    # that acts on behalf of the given user.
    #
    # @param [String] user_email
    #   The email of the user.
    # @return [Google::APIClient]
    #   Client instance
    def build_client(user_email)
      key = Google::APIClient::PKCS12.load_key(SERVICE_ACCOUNT_PKCS12_FILE_PATH, 'notasecret')
      asserter = Google::APIClient::JWTAsserter.new(SERVICE_ACCOUNT_EMAIL, 'https://www.googleapis.com/auth/drive', key)
      client = Google::APIClient.new
      client.authorization = asserter.authorize(user_email)
      client
    end

    def get_file_metadata(client, file_id)
      drive = client.discovered_api('drive', 'v2')
      result = client.execute(
        :api_method => drive.files.get,
        :parameters => { 'fileId' => file_id })
      if result.status == 200
        return result.data
      else
        puts "An error occurred: #{result.data['error']['message']}"
      end
    end

    def download_file(client, file)
      #https://developers.google.com/drive/web/manage-downloads
      if file['exportLinks']['application/x-vnd.oasis.opendocument.spreadsheet']
        result = client.execute(:uri => file['exportLinks']['application/x-vnd.oasis.opendocument.spreadsheet'], :parameters => { 'alt' => 'media'})
        if result.status == 200
          return result.body
        else
          puts "An error occurred: #{result.data['error']['message']}"
          return nil
        end
      else
        puts 'The file doesn\'t have any content stored on Drive.'
        return nil
      end
    end

  end

end