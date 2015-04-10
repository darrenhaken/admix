require_relative '../../lib/admix/utils/settings'
require_relative '../../lib/admix/mingle/mingle_controller'
require_relative '../../lib/admix/cfd_filler_for_worksheet'

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

    @mingle_controller = MingleController.new(settings.mingle_settings, settings.filter_file)
    @data_filler = CfdFillerForWorksheet.new(settings.google_client_settings, PATH_TO_FILE)

    print("\nYou've authorized access to the application successfully!\n")
  end

  def sync_data
    cfd_data_point = @mingle_controller.get_cards_statistics
    @data_filler.insert_cfd_data_point_for_date(cfd_data_point, Time.now)
    @data_filler.commit_changes
  end

end