class GoogleClientSettings

  attr_reader :client_id, :client_secret, :user_email,:spreadsheet_title, :worksheet_title

  def initialize(client_id, client_secret, user_email, spreadsheet_title, worksheet_title)
    @client_id = client_id
    @client_secret = client_secret
    @user_email = user_email
    @spreadsheet_title = spreadsheet_title
    @worksheet_title = worksheet_title
  end

  def self.SETTING_KEYS
    ['client_account', 'client_secret', 'user_email', 'spreadsheet_title', 'worksheet_title']
  end
end