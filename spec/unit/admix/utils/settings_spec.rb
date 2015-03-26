require 'rspec'

require_relative '../../../../lib/admix/utils/settings'
require_relative '../../../../lib/admix/utils/admix_settings_error'

RSpec.describe Settings do

  before(:all) do
    @config_path = File.expand_path('../../../../assets/yaml', __FILE__)
    @files = ['admix_settings.yaml', 'filter.yaml']
    @setting = Settings.instance
  end

  describe 'Loads setting from setting yaml file' do

    it 'returns the config file that ends with "admix/lib/config"' do
      expect(Settings.CONFIG_DIR).to end_with("admix/lib/config")
    end

    it 'returns admix_setting.yaml string as the name of the setting file' do
      expect(Settings.SETTING_FILE).to eq("admix_settings.yaml")
    end

    it 'returns mql_filter.yaml string as the name of the setting file' do
      expect(Settings.MQL_FILTER_FILE).to eq("mql_filter.yaml")
    end

    it 'loads google credentials from settings file' do
      @setting = Settings.change_dir(@config_path)
      @setting = Settings.change_files(@files)

      expected_settings = GoogleClientSettings.new('fake account', 'fake secret', 'random@email.com',
                                                   'Admix', 'CFD Test')

      @setting.load_application_settings

      expect(@setting.google_client_settings).to eq(expected_settings)
    end

    it 'loads mingle details from settings file' do
      @setting = Settings.change_dir(@config_path)
      @setting = Settings.change_files(@files)

      expected_settings = MingleSettings.new('anyusername', 'apassword!', 'URL to Mingle page',
                                             'name_of_project', '03/11/2014')

      @setting.load_application_settings

      expect(@setting.mingle_settings).to eq(expected_settings)
    end
  end

  describe "Validates YAML Settings keys and raise AdmixSettingsError when a key is missing" do
    before(:each) do
      @setting = Settings.change_dir(@config_path)
      @setting = Settings.change_files(@files)
    end

    it "validates YAML for the missing 'google_details' key" do
      @setting = Settings.change_files(['admix_settings_with_missing_google_details.yaml'])

      expect {@setting.load_application_settings}.to raise_error(AdmixSettingsError)
    end

    it "validates YAML for the missing 'mingle_details' key" do
      @setting = Settings.change_files(['admix_settings_with_missing_mingle_details.yaml'])

      expect {@setting.load_application_settings}.to raise_error(AdmixSettingsError)    end

    it "validates YAML for missing 'google_details' keys" do
      @setting = Settings.change_files(['admix_settings_with_missing_keys_for_google_details.yaml'])

      expect {@setting.load_application_settings}.to raise_error(AdmixSettingsError)
    end

    it "validates YAML for missing 'mingle_details' keys" do
      @setting = Settings.change_files(['admix_settings_with_missing_keys_for_mingle_details.yaml'])

      expect {@setting.load_application_settings}.to raise_error(AdmixSettingsError)
    end
  end

end