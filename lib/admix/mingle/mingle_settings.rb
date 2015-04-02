require_relative '../utils/settings_keys_validator'

class MingleSettings

  SETTING_KEYS = ['username', 'password', 'url', 'project_name', 'cfd_start_date']

  attr_reader :url, :username, :project_name, :password, :cfd_start_date

  def initialize(username, password, url, project_name, cfd_start_date)
    @username = username
    @password = password
    @url = url
    @project_name = project_name
    @cfd_start_date = cfd_start_date
  end

  def self.initialize_with_hash(mingle_details)
    SettingsKeysValidator.validate_keys_against_setting_keys(mingle_details.keys, SETTING_KEYS)
    MingleSettings.new(mingle_details['username'], mingle_details['password'], mingle_details['url'],
                       mingle_details['project_name'], mingle_details['cfd_start_date'])
  end

  def ==(other)
    self.class == other.class &&
        self.username == other.username &&
        self.password == other.password &&
        self.url == other.url &&
        self.project_name == other.project_name &&
        self.cfd_start_date== other.cfd_start_date
  end

  alias :eql? :==

  def hash
    [@username, @password, @url, @project_name, @cfd_start_date].hash
  end

end