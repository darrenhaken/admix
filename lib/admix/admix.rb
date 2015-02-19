require_relative 'version'

require_relative '../../lib/admix/google_drive/installed_app_authentication_manager'

class AdmixApp

  PATH_TO_FILE = File.expand_path('../../assets/auth_details.json',__FILE__)

  def initialize(auth_manager_class)
    @auth_manager_class = auth_manager_class
  end

  def start
    print("Enter Google Client ID for installed Application\n=> ")
    client_id = gets.chomp

    print("\nEnter Google Client Secret for installed Application\n=> ")
    client_secret = gets.chomp

    print("\nEnter your email address (to access your google drive files)\n=> ")
    user_email = gets.chomp

    @manager = @auth_manager_class.new(client_id, client_secret, PATH_TO_FILE, user_email)

    client_access_token = @manager.access_token
    if(!client_access_token)
      print("\nSorry, the application could not complete Athu2 process!\n" )
      return
    end
    print("\nYou've authorized access to the application successfully!\n" )
  end


end
