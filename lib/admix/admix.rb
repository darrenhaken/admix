require 'rest_client'

require_relative 'version'
require_relative '../../lib/admix/admix_controller'

class AdmixApp

  def initialize()
    @controller = AdmixController.new()
  end

  def start
    @controller.start_app
  end

  def sync
    @controller.fill_today_report
  end
end