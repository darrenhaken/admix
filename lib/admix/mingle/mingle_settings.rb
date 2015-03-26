require_relative '../utils/settings'

class MingleSettings

  attr_reader :url, :username, :project_name, :password, :cfd_start_date

  def initialize(username, password, url, project_name, cfd_start_date)
    @username = username
    @password = password
    @url = url
    @project_name = project_name
    @cfd_start_date = cfd_start_date
  end

  def self.initialize_with_hash(mingle_details)
    MingleSettings.check_keys(mingle_details.keys)
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

  private

  def self.SETTING_KEYS
    ['username', 'password', 'url', 'project_name', 'cfd_start_date']
  end

  def self.check_keys(keys)
    keys_missing = (MingleSettings.SETTING_KEYS - keys)
    unless keys_missing.empty?
      raise AdmixSettingsError.new("Settings Key/s missing: #{keys_missing}")
    end
  end

end