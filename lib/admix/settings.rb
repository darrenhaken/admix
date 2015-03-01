# Source code to be found at http://speakmy.name/2011/05/29/simple-configuration-for-ruby-apps/

require 'yaml'
require 'singleton'

require_relative '../../lib/admix/google_drive/google_client_settings'
require_relative '../../lib/admix/mingle/mingle_settings'

class AdmixSettingsError < TypeError

  attr_reader :error_message

  def initialize(error_message)
    @error_message = error_message
  end

end

class Settings

  attr_reader :filter_file
  attr_reader :google_client_settings, :mingle_settings

  include Singleton

  SETTINGS_KEYS = ['google_details', 'mingle_details']
  REQUIRED_KEYS = {
              :google_details => ['client_account', 'client_secret', 'user_email'],
              :mingle_details => ['username', 'password', 'url', 'project_name']
  }

  @settings = {}

  def load_application_settings()
    if ARGV.length != 2
      err_msg = "Wrong number of argument (first args is file settings, and the second arg is mingle filter)\n"
      raise AdmixSettingsError.new(err_msg)
    end
    settings_file = ARGV[0]
    @filter_file = ARGV[1]

    load! settings_file
    ARGV.clear
  end

  private

  def load!(filename)
    if(not File.exists?(filename))
      raise AdmixSettingsError.new("file does not exist:  #{filename} \n")
    end

    @settings = YAML::load_file(filename)
    setup_settings
  end

  private

  def setup_settings
    if @settings.is_a?(Hash)
      check_settings_keys(@settings.keys)
      create_google_settings
      create_mingle_settings
    end
  end

  def create_mingle_settings
    mingle_details = @settings['mingle_details']
    check_details_keys_for('mingle_details', mingle_details)
    @mingle_settings = MingleSettings.new(mingle_details['username'], mingle_details['password'],
                                                 mingle_details['url'], mingle_details['project_name'])
  end

  def create_google_settings
    google_details = @settings['google_details']
    check_details_keys_for('google_details', google_details)
    @google_client_settings = GoogleClientSettings.new(google_details['client_account'], google_details['client_secret'],
                                                       google_details['user_email'])
  end

  def check_details_keys_for(k, v)
    check_keys( REQUIRED_KEYS[k.to_sym], v.keys)
  end

  def check_settings_keys(keys)
    check_keys(SETTINGS_KEYS, keys)
  end

  def check_keys(required_keys, keys)
    keys_missing = (required_keys - keys)
    unless keys_missing.empty?
      raise AdmixSettingsError.new("Settings Key/s missing: #{keys_missing}")
    end
  end
end