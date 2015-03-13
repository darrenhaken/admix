require 'rest_client'

require_relative 'version'

require_relative '../../lib/admix/settings'
require_relative '../../lib/admix/google_drive/google_controller'
require_relative '../../lib/admix/google_drive/google_client_settings'
require_relative '../../lib/admix/mingle/mingle_controller'
require_relative '../../lib/admix/mingle/mingle_settings'

class AdmixApp

  PATH_TO_FILE = File.expand_path('../../assets/auth_details.json',__FILE__)

  def start_from_cml
    perform_google_auth
    setup_mingle
  end

  def start_from_settings
    settings = Settings.instance

    begin
      settings.load_application_settings
    rescue AdmixSettingsError => e
        print("Error: #{e.error_message}\n")
        exit(-1)
    end

    create_manager_with(settings.google_client_settings)
    create_mingle_with(settings.mingle_settings, settings.filter_file)
  end

  def print_statistics
    result = @mingle_controller.get_cards_statistics
    result.each do |k, v|
      print("\nNumber of cards in #{k} is #{v}")
    end
  end

  private
  def create_mingle_with(mingle_settings, filter_file_name)
    full_path_to_file = File.expand_path("../#{filter_file_name}", __FILE__)
    @mingle_controller = MingleController.new(mingle_settings, full_path_to_file)
  end

  def create_manager_with(google_settings)
    @controller = GoogleController.new(google_settings, PATH_TO_FILE)
    @controller.setup_controller

    client_access_token = @controller.access_token
    unless client_access_token
      print("\nSorry, the application could not complete Athu2 process!\n")
      return
    end
    print("\nYou've authorized access to the application successfully!\n")
  end
end