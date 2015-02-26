require 'rest_client'

require_relative 'version'

require_relative '../../lib/admix/google_drive/installed_app_authentication_manager'
require_relative '../../lib/admix/mingle/mingle_api_wrapper'
require_relative '../../lib/admix/mingle/mingle_wall_snapshot'
require_relative '../../lib/admix/mingle/mql_wrapper'
require_relative '../../lib/admix/settings'

class AdmixApp

  PATH_TO_FILE = File.expand_path('../../assets/auth_details.json',__FILE__)

  def initialize(auth_manager_class)
    @auth_manager_class = auth_manager_class
  end

  def start_from_cml
    perform_google_auth
    setup_mingle
  end

  def start_from_settings
    if ARGV.length != 2
      exit(-1)
    end
    settings_file = ARGV.at(0)
    filter_file = ARGV.at(1)

    ARGV.clear

    settings = Settings.instance
    begin
      settings.load!(settings_file)
    rescue AdmixSettingsError => e
      print(e.error_message + "\n")
      exit(-1)
    end
    create_manager_with(settings.google_details['client_account'], settings.google_details['client_secret'],
                        settings.google_details['user_email'])
    create_mingle_with(settings.mingle_details['username'], settings.mingle_details['password'],
                      settings.mingle_details['url'], settings.mingle_details['project_name'], filter_file)
  end

  def print_statistics
    print_card_statistics_for_type('Story')
    print_card_statistics_for_type('Defect')
    print_card_statistics_for_type('Power Ups')

    print_card_statistics_for_status('Next')
    print_card_statistics_for_status('A & D')
    print_card_statistics_for_status('A & D done')
    print_card_statistics_for_status('Dev')
    print_card_statistics_for_status('Dev done')
    print_card_statistics_for_status('QA')
    print_card_statistics_for_status('QA done')
  end

  def print_card_statistics_for_type(type)
    number = @mingle_wall.number_of_cards_of_type(type)
    print("Number of cards with Type #{type}: #{number}\n")
  end

  def print_card_statistics_for_status(status)
    number = @mingle_wall.number_of_cards_with_status(status)
    print("Number of cards in Status #{status}: #{number} \n")
  end

  private

  def setup_mingle
    print("\nEnter Mingle username \n=> ")
    mingle_username = gets.chomp

    print("\nEnter Mingle password \n=> ")
    mingle_password = gets.chomp

    print("\nEnter Mingle URL (without https/http and project name) \n=> ")
    mingle_url = gets.chomp

    print("\nEnter Mingle project name \n=> ")
    mingle_project_name = gets.chomp

    print("\nEnter path to mingle filter file \n=> ")
    mingle_filter_file_path = gets.chomp

    create_mingle_with(mingle_username, mingle_password, mingle_url, mingle_project_name, mingle_filter_file_path)
  end

  def create_mingle_with(mingle_username, mingle_password, mingle_url, mingle_project_name, filter_file_name)
    @mingle_wrapper = MingleAPIWrapper.new(mingle_username, mingle_password, mingle_url, RestClient)
    full_path_to_file = File.expand_path("../#{filter_file_name}", __FILE__)
    @mql_wrapper = MQLWrapper.new(full_path_to_file, 'name, type, status')
    @mingle_wrapper.get_cards_for_project(mingle_project_name, @mql_wrapper.parseYAML)
    @mingle_wall = MingleWallSnapshot.new(@mingle_wrapper.resource)
  end

  def perform_google_auth
    print("Enter Google Client ID for installed Application\n=> ")
    client_id = gets.chomp

    print("\nEnter Google Client Secret for installed Application\n=> ")
    client_secret = gets.chomp

    print("\nEnter your email address (to access your google drive files)\n=> ")
    user_email = gets.chomp

    create_manager_with(client_id, client_secret, user_email)
  end

  def create_manager_with(client_id, client_secret, user_email)
    @manager = @auth_manager_class.new(client_id, client_secret, PATH_TO_FILE, user_email)

    client_access_token = @manager.access_token
    if not client_access_token
      print("\nSorry, the application could not complete Athu2 process!\n")
      return
    end
    print("\nYou've authorized access to the application successfully!\n")
  end
end