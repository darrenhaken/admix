require 'rspec'

require_relative '../lib/admix/settings'

RSpec.describe Settings do

  before(:all) do
    @path_to_file = File.expand_path('../assets/yaml/admix_settings.yaml', __FILE__)
    @setting = Settings.instance
  end

  describe 'Loads setting from setting yaml file' do
    it 'loads google credentials from settings file' do
      @setting.load!(@path_to_file)

      expect(@setting.google_details['client_account']).to eq 'fake account'
      expect(@setting.google_details['client_secret']).to eq 'fake secret'
      expect(@setting.google_details['user_email']).to eq 'random@email.com'
    end

    it 'loads mingle details from settings file' do
      @setting.load!(@path_to_file)

      expect(@setting.mingle_details['username']).to eq 'anyusername'
      expect(@setting.mingle_details['password']).to eq 'apassword!'
      expect(@setting.mingle_details['url']).to eq 'URL to Mingle page'
      expect(@setting.mingle_details['project_name']).to eq 'name_of_project'
    end
  end

  describe "Validates YAML Settings keys and raise AdmixSettingsError when a key is missing" do
    it "validates YAML for the missing 'google_details' key" do
      file = File.expand_path('../assets/yaml/admix_settings_with_missing_google_details.yaml', __FILE__)

      expect {@setting.load!(file)}.to raise_error(AdmixSettingsError)
    end

    it "validates YAML for the missing 'mingle_details' key" do
      file = File.expand_path('../assets/yaml/admix_settings_with_missing_mingle_details.yaml', __FILE__)

      expect {@setting.load!(file)}.to raise_error(AdmixSettingsError)
    end

    it "validates YAML for missing 'google_details' keys" do
      file = File.expand_path('../assets/yaml/admix_settings_with_missing_keys_for_google_details.yaml', __FILE__)

      expect {@setting.load!(file)}.to raise_error(AdmixSettingsError)
    end

    it "validates YAML for missing 'mingle_details' keys" do
      file = File.expand_path('../assets/yaml/admix_settings_with_missing_keys_for_mingle_details.yaml', __FILE__)

      expect {@setting.load!(file)}.to raise_error(AdmixSettingsError)
    end
  end

  it 'Raises AdmixSettingsError when file is not found' do
    file = File.expand_path('../assets/yaml/does_not_exist.yaml', __FILE__)

    expect {@setting.load!(file)}.to raise_error(AdmixSettingsError)
  end
end