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

  include Singleton

  attr_reader :google_client_settings, :mingle_settings
  attr_reader :filter_file

  SETTINGS_KEYS = ['google_details', 'mingle_details']

  @settings = {}

  def load_application_settings()
    if ARGV.length != 2
      err_msg = "Wrong number of argument (first args is file settings, and the second arg is mingle filter)\n"
      raise AdmixSettingsError.new(err_msg)
    end
    settings_file = ARGV[0]
    @filter_file = ARGV[1]

    load!(settings_file)
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

  def setup_settings
    if @settings.is_a?(Hash)
      check_keys(@settings.keys)
      @google_client_settings = GoogleClientSettings.initialize_with_hash(@settings['google_details'])
      @mingle_settings = MingleSettings.initialize_with_hash(@settings['mingle_details'])
    end
  end

  def check_keys(keys)
    keys_missing = (SETTINGS_KEYS - keys)
    unless keys_missing.empty?
      raise AdmixSettingsError.new("Settings Key/s missing: #{keys_missing}")
    end
  end
end