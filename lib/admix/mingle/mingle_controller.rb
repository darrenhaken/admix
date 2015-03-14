require 'rest_client'

require_relative '../../../lib/admix/mingle/mingle_resource_loader'
require_relative '../../../lib/admix/mingle/mql_parser'
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
    @filter_file = filter_file
    @mingle_loader = MingleResourceLoader.new(mingle_settings.username, mingle_settings.password,
                                              mingle_settings.url, RestClient)
  end

  def get_cards_statistics
    mql_parser = MQLParser.new(@filter_file, SELECT_ELEMENT)

    cards_mql = mql_parser.parse
    send_request(cards_mql)
    cards = @mingle_loader.resource
    return nil unless cards

    count_mql = mql_parser.statement_for_count_since(@mingle_settings.cfd_start_date)
    send_request(count_mql)
    count = @mingle_loader.resource

    mingle_wall = MingleWallSnapshot.new(cards, count)
    mingle_statistics = MingleWallStatistics.new(mingle_wall)
    mingle_statistics.statistics_for_cfd
  end

  private
  def send_request(mql)
    begin
      @mingle_loader.get?(@mingle_settings.project_name, mql)
    rescue MingleAuthenticationError => e
      raise MingleControllerError.new(e.message)
    end
  end
end