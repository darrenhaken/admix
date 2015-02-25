# Source code to be found at http://speakmy.name/2011/05/29/simple-configuration-for-ruby-apps/

require 'yaml'
require 'singleton'

class AdmixSettingsError < TypeError

  attr_reader :error_message

  def initialize(error_message)
    @error_message = error_message
  end

end

class Settings

  include Singleton

  SETTINGS_KEYS = ['google_details', 'mingle_details']
  REQUIRED_KEYS = {
              :google_details => ['client_account', 'client_secret', 'user_email'],
              :mingle_details => ['username', 'password', 'url', 'project_name']
  }

  @settings = {}

  def load!(filename)
    if(not File.exists?(filename))
      raise AdmixSettingsError.new("file does not exist:  #{filename}")
    end

    @settings = YAML::load_file(filename)
    setup_settings
  end

  private

  def setup_settings
    if @settings.is_a?(Hash)
      check_settings_keys(@settings.keys)
      @settings.each do |k, v|
        check_details_keys_for(k, v)
        create_attribute(k, v)
      end
    end
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

  def create_attribute(k, v)
    attribute = k.to_sym
    self.class.module_eval {attr_accessor attribute}
    self.send("#{attribute}=",v)
  end
end