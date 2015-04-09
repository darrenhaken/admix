require 'rest_client'

require_relative '../../../lib/admix/mingle/mingle_resource_loader'
require_relative '../../../lib/admix/mingle/mql_controller'
require_relative '../../../lib/admix/mingle/mingle_settings'
require_relative '../../../lib/admix/mingle/mingle_wall_snapshot'
require_relative '../../../lib/admix/mingle/mingle_wall_statistics'

class MingleControllerError < StandardError

  attr_reader :message

  def initialize(error_message)
    @message = error_message
  end

end

class MingleController

  SELECT_ELEMENT = 'Name, Type, Status'

  def initialize(mingle_settings, filter_file)
    @mingle_settings = mingle_settings
    @mql_controller = MQLController.new(filter_file)
    @card_property_to_select = MQLCardProperty.name.and(MQLCardProperty.status).and(MQLCardProperty.type)
    @mingle_loader = MingleResourceLoader.new(mingle_settings.username, mingle_settings.password,
                                              mingle_settings.url, RestClient)
  end

  def get_cards_statistics
    mingle_cards_filter = @mql_controller.format_select_statement_for_cards(@card_property_to_select)
    cards_in_xml_format = send_request(mingle_cards_filter)
    return nil unless cards_in_xml_format

    number_of_cards_in_xml_format = get_number_of_cards_live

    mingle_wall = MingleWallSnapshot.new(cards_in_xml_format, number_of_cards_in_xml_format)

    mingle_statistics = MingleWallStatistics.new(mingle_wall)
    mingle_statistics.statistics_for_cfd
  end

  private
  def send_request(mql)
    begin
      @mingle_loader.get?(@mingle_settings.project_name, mql)
    rescue MingleAuthenticationError => e
      print("\nIncorrect Mingle username/password. Please Update the mingle settings in admix setting file\n")
      exit(-1)
    end
  end

  def get_number_of_cards_live
    count_mql = @mql_controller.format_count_statement_for_card_live_since(@mingle_settings.cfd_start_date)
    send_request(count_mql)
  end
end