require 'rest_client'

require_relative 'version'

require_relative '../../lib/admix/google_drive/installed_app_authentication_manager'
require_relative '../../lib/admix/mingle/mingle_api_wrapper'
require_relative '../../lib/admix/mingle/mingle_wall_snapshot'
require_relative '../../lib/admix/mingle/mql_wrapper'

class AdmixApp

  PATH_TO_FILE = File.expand_path('../../assets/auth_details.json',__FILE__)

  def initialize(auth_manager_class)
    @auth_manager_class = auth_manager_class
  end

  def start
    perform_google_auth
    setup_mingle
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

    @mingle_wrapper = MingleAPIWrapper.new(mingle_username, mingle_password, mingle_url, RestClient)
    @mql_wrapper = MQLWrapper.new(mingle_filter_file_path, 'name, type, status')
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

    @manager = @auth_manager_class.new(client_id, client_secret, PATH_TO_FILE, user_email)

    client_access_token = @manager.access_token
    if not client_access_token
      print("\nSorry, the application could not complete Athu2 process!\n")
      return
    end
    print("\nYou've authorized access to the application successfully!\n")
  end


end
