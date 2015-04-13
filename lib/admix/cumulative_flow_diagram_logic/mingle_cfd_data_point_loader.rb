require 'rest_client'

require_relative '../mingle/mingle_settings'
require_relative '../mingle/mingle_resource_loader'
require_relative '../mingle/mql_controller'
require_relative '../mingle/mingle_wall_snapshot'
require_relative 'mingle_cfd_data_point'

class MingleCfdDataPointLoader

  DATE_FORMAT = '%d/%m/%Y'

  def initialize(mingle_settings, filter_file)
    @mingle_settings = mingle_settings
    @mql_controller = MQLController.new(filter_file)
    @mingle_loader = MingleResourceLoader.new(mingle_settings.username, mingle_settings.password,
                                              mingle_settings.url, RestClient)
  end
  
  def get_today_cfd_data_point
    get_cfd_data_point_on_date(Time.now.strftime(DATE_FORMAT))
  end

  def get_cfd_data_point_on_date(date)
    cards_in_xml_format = get_cards_in_mingle_wall_as_of_date(date)
    return nil unless cards_in_xml_format

    number_of_cards_in_xml_format = get_number_of_cards_live_since_as_of_date(@mingle_settings.cfd_start_date, date)

    mingle_wall = MingleWallSnapshot.new(cards_in_xml_format, number_of_cards_in_xml_format)

    cfd_data_point = MingleCfdDataPoint.new(mingle_wall)
    cfd_data_point.data_point
  end

  private
  def get_cards_in_mingle_wall_as_of_date(date)
    card_property_to_select = MQLCardProperty.name.and(MQLCardProperty.status).and(MQLCardProperty.type)
    mingle_cards_filter = @mql_controller.format_select_statement_for_cards_in_date(card_property_to_select, date)
    send_request(mingle_cards_filter)
  end

  def get_number_of_cards_live_since_as_of_date(live_since, as_of_date)
    count_mql = @mql_controller.format_count_statement_for_card_live_since_as_of_date(live_since, as_of_date)
    send_request(count_mql)
  end

  def send_request(mql)
    begin
      @mingle_loader.get(@mingle_settings.project_name, mql)
    rescue MingleAuthenticationError => e
      print("\nIncorrect Mingle username/password. Please Update the mingle settings in admix setting file\n")
      exit(-1)
    end
  end

end