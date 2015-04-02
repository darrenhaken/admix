require_relative '../utils/settings_keys_validator'

class GoogleClientSettings

  SETTINGS_KEYS = ['client_account', 'client_secret', 'user_email', 'spreadsheet_title', 'worksheet_title']

  attr_reader :client_id, :client_secret, :user_email,:spreadsheet_title, :worksheet_title

  def initialize(client_id, client_secret, user_email, spreadsheet_title, worksheet_title)
    @client_id = client_id
    @client_secret = client_secret
    @user_email = user_email
    @spreadsheet_title = spreadsheet_title
    @worksheet_title = worksheet_title
  end

  def self.initialize_with_hash(google_details)
    SettingsKeysValidator.validate_keys_against_setting_keys(google_details.keys, SETTINGS_KEYS)
    GoogleClientSettings.new(google_details['client_account'], google_details['client_secret'],
                             google_details['user_email'], google_details['spreadsheet_title'],
                             google_details['worksheet_title'])
  end

  def ==(other)
    self.class == other.class &&
        self.client_id == other.client_id &&
        self.client_secret == other.client_secret &&
        self.user_email == other.user_email &&
        self.spreadsheet_title == other.spreadsheet_title &&
        self.worksheet_title == other.worksheet_title
  end

  alias :eql? :==

  def hash
    [@client_id, @client_secret, @user_email, @spreadsheet_title, @worksheet_title].hash
  end
end