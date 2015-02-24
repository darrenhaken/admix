require 'rspec'

require_relative '../lib/admix/google_drive/installed_app_authentication_manager'
require_relative '../lib/admix/admix'

RSpec.describe AdmixApp do

  describe "Allow the user to authorise access to the application (client)" do

    before(:all) do
      @manager_class = InstalledApplication::AuthenticationManager
      @admix = AdmixApp.new(@manager_class)
      @total_number_of_user_inputs = 3
    end

    before(:each) do
      allow_any_instance_of(AdmixApp).to receive(:print)
      allow_any_instance_of(AdmixApp).to receive(:gets).and_return("")
      allow_any_instance_of(InstalledApplication::AuthenticationManager).to receive(:access_token).and_return("an_access_token")
    end

    it "Asks user for client_id" do
      @admix.start

      expect(@admix).to(have_received(:print).with("Enter Google Client ID for installed Application\n=> ").once)
      expect(@admix).to(have_received(:gets).exactly(@total_number_of_user_inputs))
    end

    it "Asks user for client secret" do
      @admix.start

      expect(@admix).to(have_received(:print).with("\nEnter Google Client Secret for installed Application\n=> ").once)
      expect(@admix).to(have_received(:gets).exactly(@total_number_of_user_inputs))
    end

    it "Asks user for user email address" do
      @admix.start

      expect(@admix).to(have_received(:print).with("\nEnter your email address (to access your google drive files)\n=> ").once)
      expect(@admix).to(have_received(:gets).exactly(@total_number_of_user_inputs))
    end

    it "shows authorization success message when authorisation passes" do
      allow_any_instance_of(InstalledApplication::AuthenticationManager).to receive(:access_token).and_return("an_access_token")

      @admix.start

      expect(@admix).to(have_received(:print).with("\nYou've authorized access to the application successfully!\n"))
    end

    it "shows a failure message when the authorisation/authentication fails" do
      allow_any_instance_of(InstalledApplication::AuthenticationManager).to receive(:access_token).and_return(nil)

      @admix.start

      expect(@admix).to(have_received(:print).with("\nSorry, the application could not complete Athu2 process!\n"))
    end
  end

end