require 'rspec'

require_relative '../../lib/admix/settings'

RSpec.describe Settings do

  before(:all) do
    @path_to_file = File.expand_path('../../assets/yaml/admix_settings.yaml', __FILE__)
    @setting = Settings.instance
  end

  describe "Read config files names from command line" do

    it "Exists when the ARGV length is less than 2" do
      stub_const("ARGV", [])

      expect{@setting.load_application_settings}.to raise_error AdmixSettingsError
    end

    it "Exists when the ARGV length is larger than 2" do
      stub_const("ARGV", ['1', '2', '3'])

      expect{@setting.load_application_settings}.to raise_error AdmixSettingsError
    end
  end

  describe 'Loads setting from setting yaml file' do
    it 'loads google credentials from settings file' do
      stub_const("ARGV", [@path_to_file, 'filter.yaml'])
      @setting.load_application_settings

      expect(@setting.google_client_settings.client_id).to eq 'fake account'
      expect(@setting.google_client_settings.client_secret).to eq 'fake secret'
      expect(@setting.google_client_settings.user_email).to eq 'random@email.com'
    end

    it 'loads mingle details from settings file' do
      stub_const("ARGV", [@path_to_file, 'filter.yaml'])
      @setting.load_application_settings

      expect(@setting.mingle_settings.username).to eq 'anyusername'
      expect(@setting.mingle_settings.password).to eq 'apassword!'
      expect(@setting.mingle_settings.url).to eq 'URL to Mingle page'
      expect(@setting.mingle_settings.project_name).to eq 'name_of_project'
      expect(@setting.mingle_settings.cfd_start_date).to eq '03/11/2014'
    end
  end

  describe "Validates YAML Settings keys and raise AdmixSettingsError when a key is missing" do
    it "validates YAML for the missing 'google_details' key" do
      file = File.expand_path('../assets/yaml/admix_settings_with_missing_google_details.yaml', __FILE__)
      stub_const("ARGV", [file, 'filter.yaml'])

      expect {@setting.load_application_settings}.to raise_error(AdmixSettingsError)
    end

    it "validates YAML for the missing 'mingle_details' key" do
      file = File.expand_path('../assets/yaml/admix_settings_with_missing_mingle_details.yaml', __FILE__)
      stub_const("ARGV", [file, 'filter.yaml'])

      expect {@setting.load_application_settings}.to raise_error(AdmixSettingsError)    end

    it "validates YAML for missing 'google_details' keys" do
      file = File.expand_path('../assets/yaml/admix_settings_with_missing_keys_for_google_details.yaml', __FILE__)
      stub_const("ARGV", [file, 'filter.yaml'])

      expect {@setting.load_application_settings}.to raise_error(AdmixSettingsError)
    end

    it "validates YAML for missing 'mingle_details' keys" do
      file = File.expand_path('../assets/yaml/admix_settings_with_missing_keys_for_mingle_details.yaml', __FILE__)
      stub_const("ARGV", [file, 'filter.yaml'])

      expect {@setting.load_application_settings}.to raise_error(AdmixSettingsError)
    end
  end

  it 'Raises AdmixSettingsError when file is not found' do
    file = File.expand_path('../assets/yaml/does_not_exist.yaml', __FILE__)
    stub_const("ARGV", [file, 'filter.yaml'])

    expect {@setting.load_application_settings}.to raise_error(AdmixSettingsError)
  end
end