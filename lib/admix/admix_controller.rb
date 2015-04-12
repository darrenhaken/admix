require_relative '../../lib/admix/utils/settings'
require_relative '../../lib/admix/cumulative_flow_diagram_logic/mingle_cfd_data_point_loader'
require_relative '../../lib/admix/cumulative_flow_diagram_logic/cfd_filler_for_worksheet'

class AdmixController

  PATH_TO_FILE = File.expand_path('../../assets/auth_details.json',__FILE__)

  def start_app
    settings = Settings.instance

    begin
      settings.load_application_settings
    rescue AdmixSettingsError => e
      print("Error: #{e.error_message}\n")
      exit(-1)
    end

    @cfd_data_loader = MingleCfdDataPointLoader.new(settings.mingle_settings, settings.filter_file)
    @data_filler = CfdFillerForWorksheet.new(settings.google_client_settings, PATH_TO_FILE)

    print("\nYou've authorized access to the application successfully!\n")
  end

  def sync_data
    cfd_data_point = @cfd_data_loader.get_today_cfd_data_point
    @data_filler.insert_cfd_data_point_for_date(cfd_data_point, Time.now)
    @data_filler.commit_changes
  end

end