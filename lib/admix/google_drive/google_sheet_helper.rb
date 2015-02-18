require 'google_drive'

class GoogleSheetHelper

  def initialize(client_manager)
    @client_manager = client_manager
    @access_token = @client_manager.access_token
    @session = GoogleDrive.login_with_oauth(@access_token)
  end

  def list_all_files
    @session.spreadsheets
  end

  def get_sheet_with_title(title)
    @session.spreadsheet_by_title title
  end

end