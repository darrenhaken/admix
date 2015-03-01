require 'rspec'

require_relative '../lib/admix/admix'
require_relative '../lib/admix/mingle/mingle_resource_loader'
require_relative '../lib/admix/mingle/mingle_wall_snapshot'
require_relative '../lib/admix/mingle/mql_parser'
require_relative '../lib/admix/settings'

RSpec.describe AdmixApp do

  before(:all) do
    @admix_app_path = File.absolute_path('../../lib/admix/',__FILE__)
    @admix = AdmixApp.new()
    @total_number_of_user_inputs = 8
  end

  before(:each) do
    @settings = Settings.instance
    allow_any_instance_of(Settings).to receive(:instance).and_return(@settings)
    allow(@settings).to receive(:load!).and_return(anything)
    allow(@settings).to receive(:google_details).and_return({'client_account' => 'anything', 'client_secret' => 'anything',
                                                             'user_email'=> 'anything'})
    allow(@settings).to receive(:mingle_details).and_return({'username' => 'anything', 'password' => 'anything',
                                                             'url'=> 'anything', 'project_name' => 'anything'})

    allow_any_instance_of(AdmixApp).to receive(:print)
    allow_any_instance_of(AdmixApp).to receive(:gets).and_return("")

    allow_any_instance_of(MQLParser).to receive(:initialize).and_return(anything)
    allow_any_instance_of(MQLParser).to receive(:parse).and_return(anything)

    allow_any_instance_of(MingleResourceLoader).to receive(:load_cards_for_project?).and_return(anything)
    allow_any_instance_of(MingleWallSnapshot).to receive(:initialize).and_return(anything)

    allow_any_instance_of(GoogleController).to receive(:access_token).and_return("an_access_token")
  end

  describe "Create dependent objects" do

    before(:all) do
      @admix = AdmixApp.new()
    end

    before(:each) do
      @user_input = "user_input"
      allow_any_instance_of(AdmixApp).to receive(:gets).and_return(@user_input)
      stub_const("ARGV", ['setting.yaml', 'filter.yaml'])
      google_settings = GoogleClientSettings.new('client_id', 'client_password', 'client_user_email')
      allow(@settings).to receive(:google_client_settings){google_settings}

      mingle_settings = MingleSettings.new('username', 'password', 'uri', 'project name')
      allow(@settings).to receive(:mingle_settings){mingle_settings}
    end

    it "Creates MingleResourceLoader from user inputs" do
      expected_receive = receive(:initialize).with(@user_input, @user_input, @user_input, RestClient)
      expect_any_instance_of(MingleResourceLoader).to(expected_receive.once)

      @admix.start_from_cml
    end

    it "Creates MingleResourceLoader from settings" do
      expected_receive = receive(:initialize).with('username', 'password', 'uri', RestClient)
      expect_any_instance_of(MingleResourceLoader).to(expected_receive.once)

      @admix.start_from_settings
    end

    it 'Creates MQLParser from file input' do
      expected_receive = receive(:initialize).with(@admix_app_path+'/'+@user_input, 'name, type, status')
      expect_any_instance_of(MQLParser).to(expected_receive.once)

      @admix.start_from_cml
    end

    it 'Creates MQLParser from command line file name' do
      expected_receive = receive(:initialize).with(@admix_app_path + '/filter.yaml', 'name, type, status')
      allow(@settings).to receive(:filter_file){'filter.yaml'}
      expect_any_instance_of(MQLParser).to(expected_receive.once)

      @admix.start_from_settings
    end

    it "Creates MingleWallSnapshot" do
      mingle_xml = File.read(File.expand_path('../assets/xml/mingle_wall_snapshot_with_five_cards.xml', __FILE__))
      allow_any_instance_of(MingleResourceLoader).to receive(:resource).and_return(mingle_xml)

      expect_any_instance_of(MingleWallSnapshot).to receive(:initialize).with(mingle_xml)

      @admix.start_from_cml
    end
  end

  describe "Prompt the user for mingle details" do

    it 'Asks user for mingle username' do
      @admix.start_from_cml

      expect(@admix).to(have_received(:print).with("\nEnter Mingle username \n=> ").once)
      expect(@admix).to(have_received(:gets).exactly(@total_number_of_user_inputs))
    end

    it 'Asks user for mingle password' do
      @admix.start_from_cml

      expect(@admix).to(have_received(:print).with("\nEnter Mingle password \n=> ").once)
      expect(@admix).to(have_received(:gets).exactly(@total_number_of_user_inputs))
    end

    it "Asks user for mingle URL" do
      @admix.start_from_cml

      expect(@admix).to(have_received(:print).with("\nEnter Mingle URL (without https/http and project name) \n=> ").once)
      expect(@admix).to(have_received(:gets).exactly(@total_number_of_user_inputs))
    end

    it "Asks user for mingle project name" do
      @admix.start_from_cml

      expect(@admix).to(have_received(:print).with("\nEnter Mingle project name \n=> ").once)
      expect(@admix).to(have_received(:gets).exactly(@total_number_of_user_inputs))
    end

    it "Asks user for mingle wall filter file" do
      @admix.start_from_cml

      expect(@admix).to(have_received(:print).with("\nEnter path to mingle filter file \n=> ").once)
      expect(@admix).to(have_received(:gets).exactly(@total_number_of_user_inputs))
    end
  end

  describe "Allow the user to authorise access to the application (client)" do

    it "Asks user for client_id" do
      @admix.start_from_cml

      expect(@admix).to(have_received(:print).with("Enter Google Client ID for installed Application\n=> ").once)
      expect(@admix).to(have_received(:gets).exactly(@total_number_of_user_inputs))
    end

    it "Asks user for client secret" do
      @admix.start_from_cml

      expect(@admix).to(have_received(:print).with("\nEnter Google Client Secret for installed Application\n=> ").once)
      expect(@admix).to(have_received(:gets).exactly(@total_number_of_user_inputs))
    end

    it "Asks user for user email address" do
      @admix.start_from_cml

      expect(@admix).to(have_received(:print).with("\nEnter your email address (to access your google drive files)\n=> ").once)
      expect(@admix).to(have_received(:gets).exactly(@total_number_of_user_inputs))
    end

    it "shows authorization success message when authorisation passes" do
      allow_any_instance_of(GoogleController).to receive(:access_token).and_return("an_access_token")

      @admix.start_from_cml

      expect(@admix).to(have_received(:print).with("\nYou've authorized access to the application successfully!\n"))
    end

    it "shows a failure message when the authorisation/authentication fails" do
      allow_any_instance_of(GoogleController).to receive(:access_token).and_return(nil)

      @admix.start_from_cml

      expect(@admix).to(have_received(:print).with("\nSorry, the application could not complete Athu2 process!\n"))
    end
  end

end