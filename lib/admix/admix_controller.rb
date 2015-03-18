require_relative '../../lib/admix/settings'
require_relative '../../lib/admix/google_drive/google_controller'
require_relative '../../lib/admix/google_drive/google_client_settings'
require_relative '../../lib/admix/mingle/mingle_controller'
require_relative '../../lib/admix/mingle/mingle_settings'

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

    create_google_controller(settings.google_client_settings)
    create_mingle_controller(settings.mingle_settings, settings.filter_file)
  end

  def sync_data
    data = @mingle_controller.get_cards_statistics
    @google_controller.insert_cfd_to_spreadsheet(data)
  end

  private
  def create_mingle_controller(mingle_settings, filter_file_name)
    full_path_to_file = File.expand_path("../#{filter_file_name}", __FILE__)
    @mingle_controller = MingleController.new(mingle_settings, full_path_to_file)
  end

  def create_google_controller(google_settings)
    @google_controller = GoogleController.new(google_settings, PATH_TO_FILE)
    @google_controller.setup_controller

    client_access_token = @google_controller.access_token
    unless client_access_token
      print("\nSorry, the application could not complete Athu2 process!\n")
      return
    end
    print("\nYou've authorized access to the application successfully!\n")
  end
end