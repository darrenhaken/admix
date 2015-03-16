require_relative '../../../lib/admix/settings'

class GoogleClientSettings

  attr_reader :client_id, :client_secret, :user_email,:spreadsheet_title, :worksheet_title

  def initialize(client_id, client_secret, user_email, spreadsheet_title, worksheet_title)
    @client_id = client_id
    @client_secret = client_secret
    @user_email = user_email
    @spreadsheet_title = spreadsheet_title
    @worksheet_title = worksheet_title
  end

  def self.initialize_with_hash(google_details)
    GoogleClientSettings.check_keys(google_details.keys)
    GoogleClientSettings.new(google_details['client_account'], google_details['client_secret'],
                             google_details['user_email'], google_details['spreadsheet_title'],
                             google_details['worksheet_title'])
  end

  private

  def self.SETTING_KEYS
    ['client_account', 'client_secret', 'user_email', 'spreadsheet_title', 'worksheet_title']
  end

  def self.check_keys(keys)
    keys_missing = (GoogleClientSettings.SETTING_KEYS - keys)
    unless keys_missing.empty?
      raise AdmixSettingsError.new("Settings Key/s missing: #{keys_missing}")
    end
  end

end