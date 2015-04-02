require 'yaml'
require 'singleton'

require_relative '../../../lib/admix/google_drive/google_client_settings'
require_relative '../../../lib/admix/mingle/mingle_settings'
require_relative '../utils/settings_keys_validator'
require_relative 'config_checker'
require_relative 'admix_settings_error'

class Settings

  attr :config_dir, true
  attr :files, true

  CONFIG_DIR = File.expand_path('../../../config/', __FILE__)
  SETTING_FILE = 'admix_settings.yaml'
  MQL_FILTER_FILE = 'mql_filter.yaml'

  include Singleton

  attr_reader :google_client_settings, :mingle_settings
  attr_reader :filter_file

  SETTINGS_KEYS = ['google_details', 'mingle_details']

  @settings = {}

  def initialize()
    @config_dir = CONFIG_DIR
    @files = [SETTING_FILE, MQL_FILTER_FILE]
    @filter_file = "#{CONFIG_DIR}/#{MQL_FILTER_FILE}"
  end

  def self.change_dir(config_dir)
    instance.config_dir = config_dir
    instance
  end

  def self.change_files(files)
    instance.files = files
    instance
  end

  def self.CONFIG_DIR
    instance.config_dir
  end

  def self.SETTING_FILE
    instance.files[0]
  end

  def self.MQL_FILTER_FILE
    instance.files[1]
  end

  def load_application_settings()
    config_checker = ConfigChecker.new(@config_dir, @files)
    config_checker.check_config_files

    load_settings
  end

  private
  def load_settings()
    @settings = YAML::load_file("#{@config_dir}/#{@files[0]}")
    setup_settings
  end

  def setup_settings
    SettingsKeysValidator.validate_keys_against_setting_keys(@settings.keys, SETTINGS_KEYS)
    @google_client_settings = GoogleClientSettings.initialize_with_hash(@settings['google_details'])
    @mingle_settings = MingleSettings.initialize_with_hash(@settings['mingle_details'])
  end

end